module aptos_commission::user {
    use aptos_commission::state::{Self};   
    use aptos_commission::constant;
    use aptos_framework::event;
    use std::string::String;
    use std::signer;

    friend aptos_commission::commission;

    #[event]
    struct Register has drop, store {
        source: String,
        commission: address
    }

    #[event]
    struct ModifySource has drop, store {
        old_source: String,
        new_source: String,
    }

    #[event]
    struct ModifyCommisionAddress has drop, store {
        source: String,
        commission: address
    }

    #[event]
    struct ModifyUserSource has drop, store {
        source: String,
    }

    public entry fun register(
        sender: &signer, 
        source: String, 
        commission: address
    ) {
        assert!(source.length() <= constant::get_max_source_length(), constant::error_source_too_long());
        assert!(!state::check_source_exists(source), constant::error_source_exists());

        let sender_address = signer::address_of(sender);

        state::add_source_info(source, 0, commission, sender_address);

        state::change_user_source(sender_address, source);

        event::emit(Register {
            source,
            commission
        })
    }

    public entry fun modify_source(
        sender: &signer, 
        new_source: String,
    ) {
        assert!(new_source.length() <= constant::get_max_source_length(), constant::error_source_too_long());
        assert!(!state::check_source_exists(new_source), constant::error_source_exists());

        let sender_address = signer::address_of(sender);

        let old_source = state::get_user_source(sender_address);

        assert_is_user_admin(sender, old_source);
        assert!(new_source != old_source, constant::error_source_is_same());

        state::change_user_source(sender_address, new_source);
        
        state::change_source(old_source, new_source);

        event::emit(ModifySource {
            old_source,
            new_source
        })
    }

    public entry fun modify_commission_address(
        sender: &signer, 
        commission: address,
    ) {
        let sender_address = signer::address_of(sender);

        let source = state::get_user_source(sender_address);

        assert_is_user_admin(sender, source);

        state::modify_source_commission(source, commission);

        event::emit(ModifyCommisionAddress {
            source,
            commission
        })
    }

    public entry fun modify_user_source(
        sender: &signer, 
        source: String,
    ) {
        assert!(source.length() <= constant::get_max_source_length(), constant::error_source_too_long());

        assert!(state::check_source_exists(source), constant::error_source_not_exists());

        let sender_address = signer::address_of(sender);

        state::change_user_source(sender_address, source);

        event::emit(ModifyUserSource {
            source
        })
    }

    fun assert_is_user_admin(
        sender: &signer,
        source: String
    ) {
        let sender_address = signer::address_of(sender);

        assert!(state::check_source_exists(source), constant::error_source_not_exists());

        let admin = state::get_source_admin(source);

        assert!(admin == sender_address, constant::error_user_is_not_admin());
    }
}