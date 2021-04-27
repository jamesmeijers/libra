//! account: alice, 1000000GAS
//! account: bob, 10000GAS
//! account: carl, 10000GAS, 0, validator

// Check autopay is triggered in block prologue correctly i.e., middle of epoch boundary

//! new-transaction
//! sender: libraroot
script {
    use 0x1::AccountLimits;
    use 0x1::CoreAddresses;
    use 0x1::GAS::GAS;
    fun main(account: &signer) {
        AccountLimits::update_limits_definition<GAS>(account, CoreAddresses::LIBRA_ROOT_ADDRESS(), 0, 25, 0, 1);
    }
}
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: libraroot
//! execute-as: alice
script {
use 0x1::AccountLimits;
use 0x1::GAS::GAS;
fun main(lr: &signer, alice_account: &signer) {
    AccountLimits::publish_unrestricted_limits<GAS>(alice_account);
    AccountLimits::update_limits_definition<GAS>(lr, {{alice}}, 0, 25, 0, 1);
    AccountLimits::publish_window<GAS>(lr, alice_account, {{alice}});
}
}
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: libraroot
//! execute-as: bob
script {
use 0x1::AccountLimits;
use 0x1::GAS::GAS;
fun main(lr: &signer, bob_account: &signer) {
    AccountLimits::publish_unrestricted_limits<GAS>(bob_account);
    AccountLimits::update_limits_definition<GAS>(lr, {{bob}}, 0, 25, 0, 1);
    AccountLimits::publish_window<GAS>(lr, bob_account, {{bob}});
}
}
// check: "Keep(EXECUTED)"


// creating the payment
//! new-transaction
//! sender: alice
script {
  use 0x1::AutoPay;
  use 0x1::Signer;
  fun main(sender: &signer) {
    AutoPay::enable_autopay(sender);
    assert(AutoPay::is_enabled(Signer::address_of(sender)), 0);
    
    AutoPay::create_instruction(sender, 1, 3, {{bob}}, 100, 100);

    let (type, payee, end_epoch, amt) = AutoPay::query_instruction(Signer::address_of(sender), 1);
    assert(type == 3, 1);
    assert(payee == {{bob}}, 1);
    assert(end_epoch == 100, 1);
    assert(amt == 100, 1);
  }
}
// check: EXECUTED

// Checking balance before autopay module
//! new-transaction
//! sender: libraroot
script {
  use 0x1::LibraAccount;
  use 0x1::GAS::GAS;
  fun main() {
    let alice_balance = LibraAccount::balance<GAS>({{alice}});
    let bob_balance = LibraAccount::balance<GAS>({{bob}});
    assert(alice_balance==1000000, 1);
    assert(bob_balance == 10000, 2);
    }
}
// check: EXECUTED

///////////////////////////////////////////////////
///// Trigger Autopay Tick at 31 secs           ////
/// i.e. 1 second after 1/2 epoch  /////
//! block-prologue
//! proposer: carl
//! block-time: 31000000
//! round: 23
///////////////////////////////////////////////////


// Weird. This next block needs to be added here otherwise the prologue above does not run.
///////////////////////////////////////////////////
///// Trigger Autopay Tick at 31 secs           ////
/// i.e. 1 second after 1/2 epoch  /////
//! block-prologue
//! proposer: carl
//! block-time: 32000000
//! round: 24
///////////////////////////////////////////////////

//! new-transaction
//! sender: libraroot
script {
  use 0x1::LibraAccount;
  use 0x1::GAS::GAS;
  use 0x1::Debug::print;
  fun main(_vm: &signer) {
    let ending_balance = LibraAccount::balance<GAS>({{alice}});
    print(&ending_balance);
    let ending_balance = LibraAccount::balance<GAS>({{bob}});
    print(&ending_balance);
    // assert(ending_balance < 1000000, 7357003);
    // assert(ending_balance == 950001, 7357004);
  }
}
// check: EXECUTED

///////////////////////////////////////////////////
///// Trigger Autopay Tick at 31 secs           ////
/// i.e. 1 second after 1/2 epoch  /////
//! block-prologue
//! proposer: carl
//! block-time: 61000000
//! round: 65
///////////////////////////////////////////////////

///////////////////////////////////////////////////
///// Trigger Autopay Tick at 31 secs           ////
/// i.e. 1 second after 1/2 epoch  /////
//! block-prologue
//! proposer: carl
//! block-time: 62000000
//! round: 66
///////////////////////////////////////////////////


//! new-transaction
//! sender: libraroot
script {
  use 0x1::LibraAccount;
  use 0x1::GAS::GAS;
  use 0x1::Debug::print;
  fun main(_vm: &signer) {
    let ending_balance = LibraAccount::balance<GAS>({{alice}});
    print(&ending_balance);
    let ending_balance = LibraAccount::balance<GAS>({{bob}});
    print(&ending_balance);
    // assert(ending_balance < 1000000, 7357003);
    // assert(ending_balance == 950001, 7357004);
  }
}
// check: EXECUTED

///////////////////////////////////////////////////
///// Trigger Autopay Tick at 31 secs           ////
/// i.e. 1 second after 1/2 epoch  /////
//! block-prologue
//! proposer: carl
//! block-time: 122000000
//! round: 67
///////////////////////////////////////////////////

///////////////////////////////////////////////////
///// Trigger Autopay Tick at 31 secs           ////
/// i.e. 1 second after 1/2 epoch  /////
//! block-prologue
//! proposer: carl
//! block-time: 123000000
//! round: 68
///////////////////////////////////////////////////


//! new-transaction
//! sender: libraroot
script {
  use 0x1::LibraAccount;
  use 0x1::GAS::GAS;
  use 0x1::Debug::print;
  fun main(_vm: &signer) {
    let ending_balance = LibraAccount::balance<GAS>({{alice}});
    print(&ending_balance);
    let ending_balance = LibraAccount::balance<GAS>({{bob}});
    print(&ending_balance);
    // assert(ending_balance < 1000000, 7357003);
    // assert(ending_balance == 950001, 7357004);
  }
}
// check: EXECUTED

///////////////////////////////////////////////////
///// Trigger Autopay Tick at 31 secs           ////
/// i.e. 1 second after 1/2 epoch  /////
//! block-prologue
//! proposer: carl
//! block-time: 183000000
//! round: 69
///////////////////////////////////////////////////

///////////////////////////////////////////////////
///// Trigger Autopay Tick at 31 secs           ////
/// i.e. 1 second after 1/2 epoch  /////
//! block-prologue
//! proposer: carl
//! block-time: 184000000
//! round: 70
///////////////////////////////////////////////////


//! new-transaction
//! sender: libraroot
script {
  use 0x1::LibraAccount;
  use 0x1::GAS::GAS;
  use 0x1::Debug::print;
  fun main(_vm: &signer) {
    let ending_balance = LibraAccount::balance<GAS>({{alice}});
    print(&ending_balance);
    let ending_balance = LibraAccount::balance<GAS>({{bob}});
    print(&ending_balance);
    // assert(ending_balance < 1000000, 7357003);
    // assert(ending_balance == 950001, 7357004);
  }
}
// check: EXECUTED

///////////////////////////////////////////////////
///// Trigger Autopay Tick at 31 secs           ////
/// i.e. 1 second after 1/2 epoch  /////
//! block-prologue
//! proposer: carl
//! block-time: 244000000
//! round: 71
///////////////////////////////////////////////////

///////////////////////////////////////////////////
///// Trigger Autopay Tick at 31 secs           ////
/// i.e. 1 second after 1/2 epoch  /////
//! block-prologue
//! proposer: carl
//! block-time: 245000000
//! round: 72
///////////////////////////////////////////////////


//! new-transaction
//! sender: libraroot
script {
  use 0x1::LibraAccount;
  use 0x1::GAS::GAS;
  use 0x1::Debug::print;
  fun main(_vm: &signer) {
    let ending_balance = LibraAccount::balance<GAS>({{alice}});
    print(&ending_balance);
    let ending_balance = LibraAccount::balance<GAS>({{bob}});
    print(&ending_balance);
    // assert(ending_balance < 1000000, 7357003);
    // assert(ending_balance == 950001, 7357004);
  }
}
// check: EXECUTED