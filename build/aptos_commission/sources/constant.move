module aptos_commission::constant {
    const DENOMINATOR: u16 = 10000;
    const MAX_SOURCE_LENGTH: u64 = 30;

    public fun get_denominator(): u16 {
        DENOMINATOR
    }

    public fun get_max_source_length(): u64 {
        MAX_SOURCE_LENGTH
    }

    const ESourceExists: u64 = 1;
    const ESourceNotExists: u64 = 2;
    const ESourceTooLong: u64 = 3;
    const ERatioInvalid: u64 = 4;
    const EFaNotEnough: u64 = 5;
    const EUnAuthorized: u64 = 6;
    const ELevelInvalid: u64 = 7;
    const EUserIsNotAdmin: u64 = 8;
    const ESourceIsSame: u64 = 9;

    public fun error_source_exists(): u64 {
        ESourceExists
    }

    public fun error_source_not_exists(): u64 {
        ESourceNotExists
    }

    public fun error_source_too_long(): u64 {
        ESourceTooLong
    }

    public fun error_ratio_invalid(): u64 {
        ERatioInvalid
    }

    public fun error_fa_not_enough(): u64 {
        EFaNotEnough
    }

    public fun error_unauthorized(): u64 {
        EUnAuthorized
    }

    public fun error_level_invalid(): u64 {
        ELevelInvalid
    }

    public fun error_user_is_not_admin(): u64 {
        EUserIsNotAdmin
    }    

    public fun error_source_is_same(): u64 {
        ESourceIsSame
    }
}