module aptos_commission::state {
    use std::smart_table::{Self, SmartTable};
    use aptos_commission::constant;
    use std::table::{Self, Table};
    use std::string::String;

    friend aptos_commission::commission;
    friend aptos_commission::admin;
    friend aptos_commission::user;

    struct SourceInfo has store {
        level: u16,
        commission: address,
        admin: address,
    }

    struct State has key {
        reserve_address: address,
        source_info: Table<String, SourceInfo>,
        lv_commission_ratio: SmartTable<u16, u16>,
    }

    public(friend) fun init_state(
        sender: &signer
    ) {
        move_to(sender, State {
            reserve_address: @reserve_addr,
            source_info: table::new(),
            lv_commission_ratio: smart_table::new(),
        });
    }

    public(friend) fun get_source_level(
        source: String
    ): u16 acquires State {
        let state = borrow_global_mut<State>(@aptos_commission);

        if (state.source_info.contains(source)) {
            state.source_info.borrow(source).level
        } else {
            0
        }
    }

    public(friend) fun get_source_commission(
        source: String
    ): address acquires State {
        let state = borrow_global_mut<State>(@aptos_commission);

        state.source_info.borrow(source).commission
    }

    public(friend) fun get_level_commission_ratio(
        level: u16
    ): u16 acquires State {
        let state = borrow_global_mut<State>(@aptos_commission);

        *state.lv_commission_ratio.borrow_with_default(level, &0)
    }

    public(friend) fun get_reserve_address(
    ): address acquires State {
        let state = borrow_global_mut<State>(@aptos_commission);
        state.reserve_address
    }

    public(friend) fun modify_level_commission_ratio(
        level: u16,
        ratio_numberator: u16,
    ) acquires State {
        assert!(ratio_numberator >= 0 && ratio_numberator <= constant::get_denominator(), constant::error_ratio_invalid());
        assert!(level > 0, constant::error_level_invalid());

        let state = borrow_global_mut<State>(@aptos_commission);

        let old_ratio = state.lv_commission_ratio.borrow_mut_with_default(level, 0);
        *old_ratio = ratio_numberator;
    }

    public(friend) fun modify_source_level(
        source: String,
        level: u16
    ) acquires State {
        let state = borrow_global_mut<State>(@aptos_commission);

        let info = state.source_info.borrow_mut(source);
        info.level = level;
    }

    public(friend) fun modify_source_commission(
        source: String,
        commission: address
    ) acquires State {
        let state = borrow_global_mut<State>(@aptos_commission);

        let info = state.source_info.borrow_mut(source);
        info.commission = commission;
    }

    public(friend) fun check_source_exists(
        source: String
    ): bool acquires State {
        let state = borrow_global_mut<State>(@aptos_commission);

        state.source_info.contains(source) 
    }

    public(friend) fun get_source_admin(
        source: String
    ): address acquires State {
        let state = borrow_global_mut<State>(@aptos_commission);

        state.source_info.borrow(source).admin
    }

    public(friend) fun add_source_info(
        source: String,
        level: u16,
        commission: address,
        admin: address
    ) acquires State {
        let state = borrow_global_mut<State>(@aptos_commission);

        let info = SourceInfo {
            level,
            commission,
            admin
        };

        state.source_info.add(source, info);
    }

    public(friend) fun change_source(
        old_source: String,
        new_source: String,
    ) acquires State {
        let state = borrow_global_mut<State>(@aptos_commission);

        let old_info = state.source_info.remove(old_source);
        state.source_info.add(new_source, old_info);
    }

    #[view]
    public fun view_reserve_address(): address acquires State {
        let state = borrow_global<State>(@aptos_commission);
        state.reserve_address
    }

    #[view]
    public fun view_source_lv(source: String): u16 acquires State {
        get_source_level(source)
    }

    #[view]
    public fun view_source_commission(source: String): address acquires State {
        let state = borrow_global<State>(@aptos_commission);
        
        state.source_info.borrow(source).commission
    }

    #[view]
    public fun view_source_admin(source: String): address acquires State {
        let state = borrow_global<State>(@aptos_commission);
        
        state.source_info.borrow(source).admin
    }

    #[view]
    public fun view_lv_ratio(lv: u16): u16 acquires State {
        get_level_commission_ratio(lv)
    }
}