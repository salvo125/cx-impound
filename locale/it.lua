local Translations = {
    error = {
        ["already_impounded"] = "Vehicle is already impounded",
        ["police_only"] = "For on-duty police only",
        ["not_registered"] = "This vehicle isn\'t registered on any citizen\'s name",
        ["un_time"] = "You are not able to un-impound this vehicle. Time left: %{timelft} minutes",
        ["no_cash"] = "You don\'t have enough cash",
        ["no_othercash"] = "This citizen does\'nt have enough cash...",
        ["no_cid_match"] = "This citizen does\'nt match vehicle owner...",
        ["no_veh"] = "You are not allowed to be in vehicle or maybe there is no vehicle close to you!",
        ["no_cid"] = "There are no citizens near by!",
    },
    success = {
        ["impound"] = "Vehicle impounded successfully",
        ["un-impound"] = "Vehicle un-impounded successfully",
    },
    info = {
    },
    menu = {
    },
    log = {
    }
}

if GetConvar('qb_locale', 'en') == 'it' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end