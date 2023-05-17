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
        ["ped_label"] = "Impounded Vehicles",
        ["menu_label"] = "Impounded Vehicles",
    },
    menu = {
        ["input_header"] ="Impound Vehicle",
        ["input_submit"] ="Submit",
        ["input_time_txt"] ="Impound time in minutes.",
        ["input_dprice_txt"] ="Depot price without decimals.",
        ["menu_back"] = "⬅ Back",
        ["buyout_iby"] = "Impounded by",
        ["buyout_oby"] = "Owned by",
        ["buyout_veh"] = "Vehicle",
        ["buyout_plate"] = "Plate",
        ["buyout_boprice"] = "Buyout price",
        ["buyout_time"] = "Impound time",
        ["buyout_itime"] = "%{itime} minutes",
        ["buyout_uni"] = "Un-impound",
        ["buyout_uni_txt"] = "Un-impound impounded vehicle!",
    },
    log = {
    }
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})