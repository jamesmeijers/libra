
/////////////////////////////////////////////////////////////////////////
// 0L Module
// Ethereum Bridge Implementation
// TODO: Make errors meaningful
/////////////////////////////////////////////////////////////////////////

address 0x1{
  module Bridge{
    use 0x1::Vector;
    use 0x1::CoreAddresses;
    use 0x1::Libra;
    use 0x1::GAS::GAS;
    use 0x1::Signer;
    use 0x1::LibraAccount;
    use 0x1::Event;
    use 0x1::FIFO;
    use 0x1::Roles;

    struct Incoming {
      id: u64,
      time: u64,
      ol_party: address,
      eth_party: vector<u8>,
      value: u64,
      challenged: bool,
      updater: address,
    }

    struct Outgoing {
      id: u64,
      time: u64,
      ol_party: address,
      eth_party: vector<u8>,
      value: u64,
    }

    struct Vote {
      tx: Incoming, 
      voted: vector<address>,
      for: u64,
      against: u64,
      challenger: address,
    }

    resource struct EthBridge{
      incoming_queue: FIFO::FIFO<Incoming>,
      challenge_queue: FIFO::FIFO<Vote>,
      id: u64,
      balance: Libra::Libra<GAS>,
      incoming_handle: Event::EventHandle<Incoming>,
      outgoing_handle: Event::EventHandle<Outgoing> 
    }

    //TODO: Reach consensus on these values
    const CHALLENGE_BLOCK_DELAY: u64 = 200;
    const VOTE_BLOCK_DELAY: u64 = 2000;
    const MIN_STAKE: u64 = 1000000;

    public fun deposit (sender: &signer, eth_recipient: vector<u8>, coin: Libra::Libra<GAS>) acquires EthBridge {
      let state = borrow_global_mut<EthBridge>(CoreAddresses::LIBRA_ROOT_ADDRESS());
      
      let tx_details = Outgoing {
        id: get_next_id(state),
        time: 0, //TODO: how to get the time?
        ol_party: Signer::address_of(sender),
        eth_party: eth_recipient,
        value: Libra::value<GAS>(&coin)
      };
      Libra::deposit(&mut state.balance, coin);

      Event::emit_event<Outgoing> (&mut state.outgoing_handle, tx_details);

    }

    public fun refund (updater: &signer, ol_recipient: address, eth_sender: vector<u8>, value: u64) acquires EthBridge {
      let addr = Signer::address_of(updater);
      assert(is_updater(updater), 1);
      let state = borrow_global_mut<EthBridge>(CoreAddresses::LIBRA_ROOT_ADDRESS());

      let tx_details = Incoming {
        id: get_next_id(state),
        time: 0, //TODO: how to get the time?
        ol_party: ol_recipient,
        eth_party: eth_sender,
        value: value,
        challenged: false,
        updater: addr,
      };

      let tx_details_event = *& tx_details;

      FIFO::push<Incoming> (&mut state.incoming_queue, tx_details);
      Event::emit_event<Incoming> (&mut state.incoming_handle, tx_details_event);

    }

    public fun challenge (operator: &signer, id: u64) acquires EthBridge {
      let addr = Signer::address_of(operator);
      assert(is_operator(operator), 1);

      let state = borrow_global_mut<EthBridge>(CoreAddresses::LIBRA_ROOT_ADDRESS());
      let i = 0;
      let l = FIFO::len<Incoming>(& state.incoming_queue);

      while (i < l) {
        let tx = FIFO::borrow_mut<Incoming>(&mut state.incoming_queue, i);
        if (tx.id == id && !tx.challenged) {
          tx.challenged = true;
          let new_vote = Vote {
            tx: *tx,
            voted: Vector::empty<address>(),
            for: 0,
            against: 0,
            challenger: addr,
          };
          FIFO::push<Vote>(&mut state.challenge_queue, new_vote);
          break
        };
        i = i + 1;
      };
      //should not reach this point, if you have, id did not exist in the queue.
      assert(false, 1);

    }

    public fun vote (operator: &signer, id: u64, is_correct: bool) acquires EthBridge {
      let addr = Signer::address_of(operator);
      assert(is_operator(operator), 1);

      let state = borrow_global_mut<EthBridge>(CoreAddresses::LIBRA_ROOT_ADDRESS());
      let i = 0;
      let l = FIFO::len<Vote>(& state.challenge_queue);

      while (i < l) {
        let tx = FIFO::borrow_mut<Vote>(&mut state.challenge_queue, i);
        if (tx.tx.id == id) {
          assert (!Vector::contains<address>(& tx.voted, & addr), 1);
          Vector::push_back<address> (&mut tx.voted, addr);
          if (is_correct == true) {
            tx.for = tx.for + 1;
          }
          else {
            tx.against = tx.against + 1;
          };

          break
        };
        i = i + 1;
      };
      //should not reach this point, if you have, id did not exist in the queue.
      assert(false, 1);

    }

    public fun process_queues (vm: &signer) acquires EthBridge {
      CoreAddresses::assert_libra_root(vm);
      let current_block = 0; //TODO: how to get current block
      //process the incoming queue
      let state = borrow_global_mut<EthBridge>(CoreAddresses::LIBRA_ROOT_ADDRESS());
      loop {
        if (FIFO::len<Incoming>(&state.incoming_queue) == 0) {
          break
        };

        let next_tx = FIFO::peek<Incoming>(&mut state.incoming_queue);
        if (current_block - next_tx.time < CHALLENGE_BLOCK_DELAY) {
          //oldest tx has not yet matured
          break
        };

        let next_tx = FIFO::pop<Incoming>(&mut state.incoming_queue);
        //TODO add checks
        if (!next_tx.challenged) {
          let coin_unlocked = Libra::withdraw(&mut state.balance, next_tx.value);
          LibraAccount::vm_deposit_with_metadata<GAS>(
            vm,
            next_tx.ol_party,
            coin_unlocked,
            b"bridge_unlock",
            b""
          );
          //TODO add event
        }
      };

      

      //process the challenge queue
      loop {
        if (FIFO::len<Vote>(&state.challenge_queue) == 0) {
          break
        };

        let next_tx = FIFO::peek<Vote>(&mut state.challenge_queue);
        if (current_block - next_tx.tx.time < VOTE_BLOCK_DELAY) {
          //oldest tx has not yet matured
          break
        };

        let next_tx = FIFO::pop<Vote>(&mut state.challenge_queue);
        //TODO add checks

        if (next_tx.for > next_tx.against) {
          //the tx is approved
          let coin_unlocked = Libra::withdraw(&mut state.balance, next_tx.tx.value);
          LibraAccount::vm_deposit_with_metadata<GAS>(
            vm,
            next_tx.tx.ol_party,
            coin_unlocked,
            b"bridge_unlock",
            b""
          );
          slash(next_tx.challenger);
          //TODO add event
        }
        else {
          //the challenge was successful, tx is denied
          slash(next_tx.tx.updater);
          //TODO add event
        };
      };


    }

    fun slash (_addr: address) {
      //TODO
    }

    public fun initialize_eth_bridge (vm: &signer) {
      CoreAddresses::assert_libra_root(vm);

      move_to<EthBridge>(vm, EthBridge{
        incoming_queue: FIFO::empty<Incoming>(),
        challenge_queue: FIFO::empty<Vote>(),
        id: 1,
        balance: Libra::zero<GAS>(),
        incoming_handle: Event::new_event_handle<Incoming>(vm),
        outgoing_handle: Event::new_event_handle<Outgoing>(vm),
      });
      
    }

    fun is_updater (updater: &signer):bool {
      //TODO: how is the updater decided on? 
      Roles::assert_validator(updater);
      true
    }

    fun is_operator (operator: &signer):bool  {
      Roles::assert_validator(operator);
      let bal = LibraAccount::balance<GAS>(Signer::address_of(operator));
      if (bal >= MIN_STAKE) {
        true
      }
      else {
        false
      }

    }

    fun get_next_id (state: &mut EthBridge): u64 {
      let i = state.id;
      state.id = state.id + 1;
      i
    }

  }
}