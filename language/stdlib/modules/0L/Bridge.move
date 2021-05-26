
/////////////////////////////////////////////////////////////////////////
// 0L Module
// Ethereum Bridge Implementation
/////////////////////////////////////////////////////////////////////////

address 0x1{
  module Bridge{
    use 0x1::Vector;
    use 0x1::CoreAddresses;
    use 0x1::Testnet::is_testnet;
    use 0x1::Libra;
    use 0x1::GAS::GAS;
    use 0x1::Signer;
    use 0x1::LibraAccount;
    use 0x1::Event;
    use 0x1::FIFO;

    struct Incoming {
      id: u64,
      time: u64,
      ol_party: address,
      eth_party: vector<u8>,
      outgoing: bool,
      value: u64,
      challenged: bool,
    }

    struct Outgoing {
      id: u64,
      time: u64,
      ol_party: address,
      eth_party: vector<u8>,
      outgoing: bool,
      value: u64,
    }

    struct vote {
      tx: Incoming, 
      voted: vector<address>,
      for: u64,
      against: u64,
    }

    resource struct EthBridge{
      operator_queue: FIFO<Incoming>,
      challenge_queue: FIFO<vote>,
      id: u64,
      balance: Libra::Libra<GAS>,
      incoming_handle: Event::EventHandle<Incoming>,
      outgoing_handle: Event::EventHandle<Outgoing> 
    }

    resource struct Outgoing_Event_Handle { 
      h: Event::EventHandle<Outgoing> 
    }



    public fun deposit (sender: &signer, eth_recipient: vector<u8>, coin: Libra::Libra<GAS>) {

    }

    public fun refund (updater: &signer, ol_recipient: address, eth_sender: vector<u8>, value: u64) {
      addr = Signer::address_of(updater);
      assert(is_updater(addr), 1);

    }

    public fun challenge (operator: &signer, id: u64) {
      addr = Signer::address_of(operator);
      assert(is_operator(addr), 1);

    }

    public fun vote (operator: &signer, id: u64, is_correct: bool) {
      addr = Signer::address_of(operator);
      assert(is_operator(addr), 1);

    }

    public fun process_queues (vm: &signer) {
      CoreAddresses::assert_libra_root(vm);

    }

    public fun initialize_eth_bridge (vm: &signer) {
      CoreAddresses::assert_libra_root(vm);

      move_to<EthBridge>(vm, EthBridge{
        operator_queue: FIFO::empty<Incoming>(),
        challenge_queue: FIFO::empty<vote>(),
        id: 1,
        balance: Libra::zero<GAS>(),
        incoming_handle: Event::new_event_handle<Incoming>(vm),
        outgoing_handle: Event::new_event_handle<Outgoing>(vm),
      });
      
    }

    fun is_updater (id: address) {

    }

    fun is operator (id: address) {

    }



    /*
    public fun init_handle(sender: &signer) {
      let account = Signer::address_of(sender);
      if (!exists<Handle>(account)) {
        Event::publish_generator(sender);
        move_to(sender, Handle { h: Event::new_event_handle(sender) })
      };
    }

    public fun emit(account: &signer, i: u64) acquires Handle{
      let addr = Signer::address_of(account);

      let handle = borrow_global_mut<Handle>(addr);

      Event::emit_event(&mut handle.h, AnEvent { i })
    }


    // TODO: Demoware, Change this to EventHandle
    

    

    public fun initialize_eth(vm: &signer){
      assert(is_testnet(), 01);
      CoreAddresses::assert_libra_root(vm);
      move_to<EthBridge>(vm, EthBridge{
        lock_history: Vector::empty<Details>(),
        unlock_history: Vector::empty<Details>(),
        queue_unlock: Vector::empty<Details>(),
        balance: Libra::zero<GAS>()
      });
    }

    // TODO: Eth_Receipient is a hex.
    public fun lock_from(sender: &signer, eth_recipient: vector<u8>, coin: Libra::Libra<GAS>) acquires EthBridge {
      assert(is_testnet(), 01);

      let state = borrow_global_mut<EthBridge>(CoreAddresses::LIBRA_ROOT_ADDRESS());
      
      Vector::push_back<Details>(&mut state.lock_history, Details {
        ol_party: Signer::address_of(sender),
        eth_party: eth_recipient,
        outgoing: true,
        value: Libra::value<GAS>(&coin)
      });
      Libra::deposit(&mut state.balance, coin);
    }

    public fun unlock_to(vm: &signer, ol_recipient: address, eth_sender: vector<u8>, value: u64) acquires EthBridge {
      assert(is_testnet(), 01);
      CoreAddresses::assert_libra_root(vm);

      let state = borrow_global_mut<EthBridge>(CoreAddresses::LIBRA_ROOT_ADDRESS());
      
      Vector::push_back<Details>(&mut state.queue_unlock, Details {
        ol_party: ol_recipient,
        eth_party: eth_sender,
        outgoing: false,
        value: value
      });
    }

    public fun process_unlock(vm: &signer, details: Details) acquires EthBridge {
      assert(is_testnet(), 01);
      CoreAddresses::assert_libra_root(vm);

      let state = borrow_global_mut<EthBridge>(CoreAddresses::LIBRA_ROOT_ADDRESS());
      

      let coin_unlocked = Libra::withdraw(&mut state.balance, details.value);
      LibraAccount::vm_deposit_with_metadata<GAS>(
        vm,
        details.ol_party,
        coin_unlocked,
        b"bridge_unlock",
        b""
      );

      // save history
      // TODO: This should be an event.
      let (_, i) = Vector::index_of<Details>(&state.queue_unlock, &details);
      Vector::remove<Details>(&mut state.queue_unlock, i);
      Vector::push_back<Details>(&mut state.unlock_history, details);
    }

    */
  }
}