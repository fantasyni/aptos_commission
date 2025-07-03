module aptos_commission::admin {
    use aptos_commission::state::{Self};    
    use aptos_commission::constant;
    use aptos_framework::event;
    use std::string::String;
    use std::signer;

    friend aptos_commission::commission;

    struct AdminCap has key {
        admin: address,
    }

    #[event]
    struct ModifyLevelCommissionRatio has drop, store {
        level: u16,
        ratio_numberator: u16
    }

    #[event]
    struct ModifySourceLevel has drop, store {
        source: String,
        level: u16,
    }
    
    public(friend) fun init_admin(sender: &signer) {
        move_to(sender, AdminCap {
            admin: @admin_addr
        });
    }

    public entry fun modify_level_commission_ratio(
        sender: &signer,
        level: u16,
        ratio_numberator: u16,
    ) acquires AdminCap {
        assert_is_admin(sender);

        state::modify_level_commission_ratio(level, ratio_numberator);

        event::emit(ModifyLevelCommissionRatio {
            level,
            ratio_numberator
        })
    }

    public entry fun modify_source_level(
        sender: &signer,
        source: String,
        level: u16
    ) acquires AdminCap {
        assert_is_admin(sender);
        
        assert!(state::check_source_exists(source), constant::error_source_not_exists());
        
        state::modify_source_level(source, level);

        event::emit(ModifySourceLevel {
            source,
            level
        })
    }

    fun assert_is_admin(minter: &signer) acquires AdminCap {
        let admin = borrow_global<AdminCap>(@aptos_commission);

        let minter_addr = signer::address_of(minter);
        assert!(minter_addr == admin.admin, constant::error_unauthorized())
    }

    #[view]
    public fun view_admin_address(): address acquires AdminCap {
        let admin = borrow_global<AdminCap>(@aptos_commission);
        admin.admin
    }
}