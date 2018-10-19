contract ProblematicConditionalPayment {
  // to keep track of the amount paid by Alice
  // when deciding on Bob’s transfer
  uint32 paid;

  // map addresses to their respective balance
  mapping (address => uint256) public balances;

  // the address of Alice’s account
  address A = 0x...;
  // the address of Bob’s account
  address B = 0x...;

  // enables execution of functions depending on invoker
  modifier onlyFrom(address _address) {
    if (msg.sender != _address) throw;
    _;
  }

  // fake top up to increase balances
  function topUp(address _address, uint32 _balance) public {
      balances[_address] += _balance;
  }

  // Alice sends money to Bob
  function sendTo(address B, uint32 _amount) onlyFrom(A) {
    // checking the sufficiency of funds available
    if (balances[A] >= _amount) {
      balances[A] -= _amount;
      balances[B] += _amount;
      // sorting the amount paid
      paid = _amount;
    }
  }

  function checkPayment(address B, uint32 _amount) onlyFrom(B) constant returns (bool result) {
    // check that Alice paid
    if (paid > _amount) {
      return true;
    } else {
      // cancel contract execution
      throw;
    }
  }

  // Bob sends money to Charly
  function sendIfReceived(address C, uint32 _amount) onlyFrom(B) {
    balances[B] -= _amount;
    balances[C] += _amount;
  }
}
