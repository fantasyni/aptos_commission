module aptos_commission::user {
    use aptos_commission::state::{Self};   
    use aptos_commission::constant;
    use aptos_framework::event;
    use std::string::String;
    use std::signer;

    friend aptos_commission::commission;

    struct UserSetting has key {
        source: String,
    }

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

    public(friend) fun get_source(
        user_address: address
    ): String acquires UserSetting {
        let setting = borrow_global<UserSetting>(user_address);
        setting.source
    }

    public(friend) fun exists_user_setting(
        user_address: address
    ): bool {
        exists<UserSetting>(user_address)
    }

    public entry fun register(
        sender: &signer, 
        source: String, 
        commission: address
    ) acquires UserSetting {
        assert!(source.length() <= constant::get_max_source_length(), constant::error_source_too_long());
        assert!(!state::check_source_exists(source), constant::error_source_exists());

        let sender_address = signer::address_of(sender);

        state::add_source_info(source, 0, commission, sender_address);

        check_add_user_source(sender, source);

        event::emit(Register {
            source,
            commission
        })
    }

    public entry fun modify_source(
        sender: &signer, 
        new_source: String,
    ) acquires UserSetting {
        assert!(new_source.length() <= constant::get_max_source_length(), constant::error_source_too_long());
        assert!(!state::check_source_exists(new_source), constant::error_source_exists());

        let sender_address = signer::address_of(sender);

        let settings = borrow_global_mut<UserSetting>(sender_address);

        let old_source = settings.source;

        assert_is_user_admin(sender, old_source);
        assert!(new_source != old_source, constant::error_source_is_same());

        settings.source = new_source;
        
        state::change_source(old_source, new_source);

        event::emit(ModifySource {
            old_source,
            new_source
        })
    }

    public entry fun modify_commission_address(
        sender: &signer, 
        commission: address,
    ) acquires UserSetting {
        let sender_address = signer::address_of(sender);

        let settings = borrow_global<UserSetting>(sender_address);

        let source = settings.source;
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
    ) acquires UserSetting {
        assert!(source.length() <= constant::get_max_source_length(), constant::error_source_too_long());

        assert!(state::check_source_exists(source), constant::error_source_not_exists());

        check_add_user_source(sender, source);

        event::emit(ModifyUserSource {
            source
        })
    }

    fun check_add_user_source(
        sender: &signer,
        source: String,
    ) acquires UserSetting {
        let sender_address = signer::address_of(sender);

        let setting_exists = exists<UserSetting>(sender_address);

        if (setting_exists) {
            let settings = borrow_global_mut<UserSetting>(sender_address);

            settings.source = source;
        } else {
            move_to(sender, UserSetting {
                source,
            });
        }
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