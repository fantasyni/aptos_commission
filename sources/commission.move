module aptos_commission::commission {
    use aptos_framework::fungible_asset::{Self, FungibleAsset};
    use aptos_framework::primary_fungible_store;
    use aptos_commission::state::{Self};
    use aptos_commission::constant;
    use aptos_commission::admin;
    use aptos_commission::math;
    use aptos_framework::event;
    use std::object::{Self};
    use std::signer;
    
    fun init_module(sender: &signer) {
        state::init_state(sender);
        admin::init_admin(sender);
    }

    #[event]
    struct TransactionCommission has drop, store {
        user_address: address,
        fa_address: address,
        fa_amount: u64,
        commission_amount: u64,
        reserve_amount: u64
    }

    public fun run_transaction_commission(
        sender: &signer,
        user_address: address,
        fa: FungibleAsset
    ) {
        let sender_address = signer::address_of(sender);

        let fa_amount = fungible_asset::amount(&fa);
        let fa_metadata = fungible_asset::asset_metadata(&fa);

        assert!(
            fa_amount > 0 && primary_fungible_store::balance(sender_address, fa_metadata) >= fa_amount,
            constant::error_fa_not_enough()
        );

        let ratio_numberator: u16 = 0;

        let setting_exists = state::exists_user_source(user_address);
        if (setting_exists) {
            let source = state::get_user_source(user_address);

            if (state::check_source_exists(source)) {
                let level = state::get_source_level(source);
                ratio_numberator = state::get_level_commission_ratio(level);
            }
        };

        let ratio_denominator = constant::get_denominator();

        assert!(ratio_numberator >= 0 && ratio_numberator <= ratio_denominator, constant::error_ratio_invalid());

        let total_amount = fa_amount;

        let commission_amount = math::safe_mul_div_u64(total_amount, ratio_numberator as u64, ratio_denominator as u64);

        let reserve_amount = total_amount - commission_amount;

        if (commission_amount > 0) {
            let commission_fa = fungible_asset::extract(&mut fa, commission_amount);

            let source = state::get_user_source(user_address);
            let commission_address = state::get_source_commission(source);
            primary_fungible_store::deposit(commission_address, commission_fa);
        };

        let reserve_address = state::get_reserve_address();

        primary_fungible_store::deposit(reserve_address, fa);

        event::emit(TransactionCommission {
            user_address,
            fa_address: object::object_address(&fa_metadata),
            fa_amount,
            commission_amount,
            reserve_amount
        })
    }
}