#[starknet::interface]
trait ITrustLenderPool<TContractState> {
    fn flashLoan(ref self: TContractState, amount: u256, borrower: ContractAddress, target: ContractAddress, calldata: Span<felt252>) -> bool;
}


#[starknet::contract]
mod side_entrance_lender_pool {
    use traits::TryInto;
    use option::OptionTrait;
    use starknet::{get_caller_address, get_contract_address, ContractAddress};
    use damnvulnerabledefi::contracts::dependencies::external::token::ERC20::{
        IERC20Dispatcher, IERC20DispatcherTrait
    };
        use damnvulnerabledefi::contracts::dependencies::external::security::reentrancy_guard::{
        IReentrancyGuard, reentrancy_guard
    };
    use damnvulnerabledefi::contracts::dependencies::external::security::reentrancy_guard::reentrancy_guard::{
        ReentrancyGuard
    };


    #[storage]
    struct Storage {
        ether_token: IERC20Dispatcher
    }


    #[constructor]
    fn constructor(ref self: ContractState, _ether_token: felt252) {
        self
            .ether_token
            .write(IERC20Dispatcher { contract_address: _ether_token.try_into().unwrap() });
    }

    impl PuppelPoolReentrancyGuard of IReentrancyGuard<ContractState> {
        fn start(ref self: ContractState) {
            let mut state = reentrancy_guard::unsafe_new_contract_state();
            ReentrancyGuard::start(ref state);
        }

        fn end(ref self: ContractState) {
            let mut state = reentrancy_guard::unsafe_new_contract_state();
            ReentrancyGuard::end(ref state);
        }
    }

    #[external(v0)]
    impl TrustLenderPool of super::ITrustLenderPool<ContractState> {
        fn flashLoan(ref self: TContractState, amount: u256, borrower: ContractAddress, target: ContractAddress, calldata: Span<felt252>) {
        PuppelPoolReentrancyGuard::start(ref self);
        let balanceBefore = self.ether_token.balanceOf(starknet::get_contract_address());

        self.token.transfer(borrower, amount);
        target.functionCall(data);

        assert(self.token.balanceOf(starknet::get_contract_address()) > balanceBefore, 'Repay failed');
        PuppelPoolReentrancyGuard::end(ref self);
        return true;
        }
    }
}

