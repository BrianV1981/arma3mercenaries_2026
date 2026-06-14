/*
    HG_VehiclesShopCfg.h
    Overhauled for A3M by A.I.M.
    Mirrored exactly from grad-listBuymenu (vehicleStoreMenu_1.hpp)
*/

class HG_DefaultShop 
{
    conditionToAccess = "true";

    class Rvehicles
    {
        displayName = "Automobiles and Recreational Vehicles";
        vehicles[] =
        {
            {"C_Kart_01_black_F", 0, "true", "Go-karts come in all shapes and forms, from motorless models to high-powered racing machines. Some, such as Superkarts, are able to beat racing cars or motorcycles on long circuits. (Slingload: No) (Slingloadable: Yes)"},
            {"B_Quadbike_01_F", 0, "true", "The ATV is an all-terrain, 4x4 light utility vehicle that is mainly designed for use by special forces units and non-combat troops. (Slingload: No) (Slingloadable: Yes)"},
            {"C_Hatchback_01_sport_F", 4000, "true", "The Hatchback is a five-door compact car with a hatchback layout. The Hatchback contains enough seats for the driver and up to a maximum of three other passengers. (Slingload: No) (Slingloadable: Yes)"},
            {"I_C_Offroad_02_unarmed_F", 6000, "true", "The Jeep Wrangler is a modern four-wheel drive off-road vehicle with a distinctive construction. The vehicle was produced in the US and exists in a number of different editions. (Slingload: No) (Slingloadable: Yes)"},
            {"C_SUV_01_F", 8000, "true", "SUV. (Slingload: No) (Slingloadable: Yes)"},
            {"I_E_Offroad_01_F", 8000, "true", "Offroad. (Slingload: No) (Slingloadable: Yes)"},
            {"I_E_Offroad_01_covered_F", 8000, "true", "Offroad. (Slingload: No) (Slingloadable: Yes)"},
            {"I_E_Offroad_01_comms_F", 8000, "true", "Offroad. (Slingload: No) (Slingloadable: Yes)"},
            {"I_C_Van_02_transport_F", 10000, "true", "	The standard van can be used for a huge variety of practical purposes. This particular model features a long load length and excellent roof height, allowing for the transport of passengers, cargo, or even some smaller vehicles. (Slingload: No) (Slingloadable: Yes)"},
            {"I_C_Van_02_vehicle_F", 10000, "true", "Rugged and flexible, the Van represents more than twenty years of innovation. It is the benchmark for hybrid minibus-style vehicles; providing a combination of reliability and customisation for a variety of roles. (Slingload: No) (Slingloadable: Yes)"},
            {"C_Van_01_box_F", 13000, "true", "The Truck is a multipurpose, medium-sized, off-road capable van designed for a variety of roles ranging from transporting freight and/or passengers, to refuelling military and civilian vehicles. (Slingload: No) (Slingloadable: Yes)"},
            {"C_Tractor_01_F", 5000, "true", "Found in farm barns across the globe, the common tractor is a reliable high torque engineering vehicle, used for towing trailers and many other agricultural tasks. This 2WD tractor with a diesel engine has proven itself reliable since the eighties. With solid maintenance and the occasional lick of fresh paint, this old workhorse has been in use by several generations of farmers to date. (Slingload: No) (Slingloadable: Yes)"}
        };
        spawnPoints[] =
        {
            {"Main Spawn",{"civilian_vehicles_spawn_1"}}
        };
    };

    class Svehicles
    {
        displayName = "Support Vehicles";
        vehicles[] =
        {
            {"I_C_Van_01_transport_F", 13000, "true", "Truck (Flatbed) can be utilized to tow other vehicles. Once activated, you can use the middle mouse wheel on the vehicle that you wish to be towed. (Slingload: No) (Slingloadable: Yes)"},
            {"I_E_Van_02_medevac_F", 15000, "true", "Ambulance (Medical Facility) will enable the use of personal aid kits (PAK's) in the field. (Slingload: No) (Slingloadable: Yes)"},
            {"B_G_Van_01_fuel_F", 15000, "true", "The Truck is a multipurpose, medium-sized, off-road capable van designed for a variety of roles ranging from transporting freight and/or passengers, to refuelling military and civilian vehicles. (Slingload: No) (Slingloadable: Yes)"},
            {"B_G_Offroad_01_repair_F", 50000, "true", "Offroad (repair facility) can be utiliezed to repair damaged vehicles to 100%. (Slingload: No) (Slingloadable: Yes)"},
            {"I_Truck_02_covered_F", 125000, "true", "The Zamak is a medium-sized 6x6, general utility truck that can be utilized to tow other vehicles. (Covered). (Slingload: No) (Slingloadable: Yes)"},
            {"I_Truck_02_medical_F", 150000, "true", "This Zamak is a mobile medical facility that can be utilized to tow other vehicles. (Slingload: No) (Slingloadable: Yes)"},
            {"C_IDAP_Truck_02_water_F", 150000, "true", "The Zamak is a medium-sized 6x6, general utility truck that can be utilized to tow other vehicles. (Covered). (Slingload: No) (Slingloadable: Yes)"},
            {"I_Truck_02_fuel_F", 150000, "true", "This Zamak is a mobile fuel station that can be utilized to tow other vehicles. (Slingload: No) (Slingloadable: Yes)"},
            {"I_Truck_02_box_F", 150000, "true", "This Zamak is a mobile repair station that can be utilized to tow other vehicles. (Slingload: No) (Slingloadable: Yes)"},
            {"I_Truck_02_ammo_F", 175000, "true", "This Zamak is a mobile ammo station that can be utilized to tow other vehicles. (Slingload: No) (Slingloadable: Yes)"},
            {"B_Truck_01_mover_F", 200000, "true", "This HEMTT is a transport vehicle that can be utilized to tow other vehicles. The HEMTT performs decently on and off-road but handles rather poorly at high speeds; not to mention the risk of rollovers when turning on sharp corners as it requires a large amount of space to turn itself even at slow speeds. (Slingload: No) (Slingloadable: Yes)"},
            {"B_Truck_01_flatbed_F", 200000, "true", "This HEMTT is equipped with a flatbed that can be utilized to tow other vehicles. The HEMTT performs decently on and off-road but handles rather poorly at high speeds; not to mention the risk of rollovers when turning on sharp corners as it requires a large amount of space to turn itself even at slow speeds. (Slingload: No) (Slingloadable: Yes)"},
            {"B_Truck_01_cargo_F", 200000, "true", "This HEMTT is a cargo vehicle that can be utilized to tow other vehicles. The HEMTT performs decently on and off-road but handles rather poorly at high speeds; not to mention the risk of rollovers when turning on sharp corners as it requires a large amount of space to turn itself even at slow speeds. (Slingload: No) (Slingloadable: Yes)"},
            {"B_Truck_01_box_F", 200000, "true", "This HEMTT is equipped with a box container that can be utilized to tow other vehicles. The HEMTT performs decently on and off-road but handles rather poorly at high speeds; not to mention the risk of rollovers when turning on sharp corners as it requires a large amount of space to turn itself even at slow speeds. (Slingload: No) (Slingloadable: Yes)"},
            {"B_Truck_01_transport_F", 200000, "true", "This HEMTT is a transport vehicle that can be utilized to tow other vehicles. The HEMTT performs decently on and off-road but handles rather poorly at high speeds; not to mention the risk of rollovers when turning on sharp corners as it requires a large amount of space to turn itself even at slow speeds. (Slingload: No) (Slingloadable: Yes)"},
            {"B_Truck_01_covered_F", 200000, "true", "This HEMTT is a transport vehicle that can be utilized to tow other vehicles. The HEMTT performs decently on and off-road but handles rather poorly at high speeds; not to mention the risk of rollovers when turning on sharp corners as it requires a large amount of space to turn itself even at slow speeds. (Slingload: No) (Slingloadable: Yes)"},
            {"B_Truck_01_medical_F", 225000, "true", "This HEMTT will enable the use of personal aid kits (PAK's) in the field and is a mobile spawn point that can be utilized to tow other vehicles. (Slingload: No) (Slingloadable: Yes)"},
            {"B_Truck_01_fuel_F", 225000, "true", "This HEMTT is a mobile fuel station that can be utilized to tow other vehicles. The HEMTT performs decently on and off-road but handles rather poorly at high speeds; not to mention the risk of rollovers when turning on sharp corners as it requires a large amount of space to turn itself even at slow speeds. (Slingload: No) (Slingloadable: Yes)"},
            {"B_Truck_01_Repair_F", 225000, "true", "This HEMTT is a mobile repair station that can be utilized to tow other vehicles. The HEMTT performs decently on and off-road but handles rather poorly at high speeds; not to mention the risk of rollovers when turning on sharp corners as it requires a large amount of space to turn itself even at slow speeds. (Slingload: No) (Slingloadable: Yes)"},
            {"B_Truck_01_ammo_F", 250000, "true", "This HEMTT is a ammo resupply vehicle that can be utilized to tow other vehicles. The HEMTT performs decently on and off-road but handles rather poorly at high speeds; not to mention the risk of rollovers when turning on sharp corners as it requires a large amount of space to turn itself even at slow speeds. (Slingload: No) (Slingloadable: Yes)"},
            {"O_T_Truck_03_transport_ghex_F", 250000, "true", "This Typhoon is a transport vehicle that can be utilized to tow other vehicles. The HEMTT performs decently on and off-road but handles rather poorly at high speeds; not to mention the risk of rollovers when turning on sharp corners as it requires a large amount of space to turn itself even at slow speeds. (Slingload: No) (Slingloadable: Yes)"},
            {"O_T_Truck_03_covered_ghex_F", 250000, "true", "This Typhoon is a transport vehicle that can be utilized to tow other vehicles. The HEMTT performs decently on and off-road but handles rather poorly at high speeds; not to mention the risk of rollovers when turning on sharp corners as it requires a large amount of space to turn itself even at slow speeds. (Slingload: No) (Slingloadable: Yes)"},
            {"O_T_Truck_03_medical_ghex_F", 275000, "true", "This Typhoon will enable the use of personal aid kits (PAK's) in the field and is a mobile spawn point that can be utilized to tow other vehicles. (Slingload: No) (Slingloadable: Yes)"},
            {"O_T_Truck_03_repair_ghex_F", 275000, "true", "This Typhoon is a mobile repair station that can be utilized to tow other vehicles. The HEMTT performs decently on and off-road but handles rather poorly at high speeds; not to mention the risk of rollovers when turning on sharp corners as it requires a large amount of space to turn itself even at slow speeds. (Slingload: No) (Slingloadable: Yes)"},
            {"O_T_Truck_03_ammo_ghex_F", 300000, "true", "This Typhoon is a ammo resupply vehicle that can be utilized to tow other vehicles. The HEMTT performs decently on and off-road but handles rather poorly at high speeds; not to mention the risk of rollovers when turning on sharp corners as it requires a large amount of space to turn itself even at slow speeds. (Slingload: No) (Slingloadable: Yes)"},
            {"B_APC_Tracked_01_CRV_F", 475000, "true", "The Nemmera is designed to serve purely as a support vehicle. Nearby friendly vehicles can be repaired, rearmed and refuelled by the Nemmera."}
        };
        spawnPoints[] =
        {
            {"Main Spawn",{"civilian_vehicles_spawn_1"}}
        };
    };

    class Cvehicles
    {
        displayName = "Combat Vehicles";
        vehicles[] =
            {"I_C_Offroad_02_LMG_F", 20000, "true", "	The 4x4 pickup by Jeep is a perfect choice for farmers and hunters. The durable chassis and powerful engine has been designed to withstand anything from the cratered highways of Central Europe to the rugged terrain of the Mediterranean. (Slingload: No) (Slingloadable: Yes)"},
            {"B_G_Offroad_01_armed_F", 20000, "true", "	The 4x4 pickup by Jeep is a perfect choice for farmers and hunters. The durable chassis and powerful engine has been designed to withstand anything from the cratered highways of Central Europe to the rugged terrain of the Mediterranean. (Slingload: No) (Slingloadable: Yes)"},
            {"I_C_Offroad_02_AT_F", 30000, "true", "	The 4x4 pickup by Jeep is a perfect choice for farmers and hunters. The durable chassis and powerful engine has been designed to withstand anything from the cratered highways of Central Europe to the rugged terrain of the Mediterranean. (Slingload: No) (Slingloadable: Yes)"},
            {"B_G_Offroad_01_AT_F", 30000, "true", "	The 4x4 pickup by Jeep is a perfect choice for farmers and hunters. The durable chassis and powerful engine has been designed to withstand anything from the cratered highways of Central Europe to the rugged terrain of the Mediterranean. (Slingload: No) (Slingloadable: Yes)"},
            {"O_T_LSV_02_unarmed_F", 150000, "true", "An agile, lightly protected vehicle for 5-6 soldiers – depending on the configuration. The LSV Mk. II offers safe and fast operating speeds with superior levels of mobility and maneuverability. It is highly adaptable to severe, rugged and restrictive terrains while providing off-road, cross-country mobility under all types of weather conditions. (Slingload: No) (Slingloadable: Yes)"},
            {"B_T_LSV_01_unarmed_F", 150000, "true", "Primarily designed for use by special operations units, the Polaris DAGOR is a lightweight, air transportable, highly mobile platform that can be configured for a variety of missions. (Slingload: No) (Slingloadable: Yes)"},
            {"O_T_LSV_02_armed_F", 175000, "true", "An agile, lightly protected vehicle for 5-6 soldiers – depending on the configuration. The LSV Mk. II offers safe and fast operating speeds with superior levels of mobility and maneuverability. It is highly adaptable to severe, rugged and restrictive terrains while providing off-road, cross-country mobility under all types of weather conditions. (Slingload: No) (Slingloadable: Yes)"},
            {"B_LSV_01_armed_F", 175000, "true", "Primarily designed for use by special operations units, the Polaris DAGOR is a lightweight, air transportable, highly mobile platform that can be configured for a variety of missions. (Slingload: No) (Slingloadable: Yes)"},
            {"O_T_LSV_02_AT_F", 190000, "true", "An agile, lightly protected vehicle for 5-6 soldiers – depending on the configuration. The LSV Mk. II offers safe and fast operating speeds with superior levels of mobility and maneuverability. It is highly adaptable to severe, rugged and restrictive terrains while providing off-road, cross-country mobility under all types of weather conditions. (Slingload: No) (Slingloadable: Yes)"},
            {"B_T_LSV_01_AT_F", 190000, "true", "Primarily designed for use by special operations units, the Polaris DAGOR is a lightweight, air transportable, highly mobile platform that can be configured for a variety of missions. (Slingload: No) (Slingloadable: Yes)"},
            {"B_MRAP_01_F", 190000, "true", "The M-ATV is a four-wheel drive, all-terrain, MRAP-type vehicle. Primarily intended for use in counter-insurgency operations, it is multi-role and can act as both a troop carrier and supply vehicle if needed. (Slingload: No) (Slingloadable: Yes)"},
            {"O_MRAP_02_F", 190000, "true", "The Karatel is a four-wheel drive MRAP-type vehicle that can fulfil many roles ranging from serving as a V.I.P. transport, escort vehicle, light troop transport, to reconnaissance. All in a well-protected and compact package. (Slingload: No) (Slingloadable: Yes)"},
            {"I_MRAP_03_F", 190000, "true", "The Fennek is a four-wheel drive armed reconnaissance vehicle. Though its primary mission is observation, it can act as both a light troop transport and scout vehicle as well. (Slingload: No) (Slingloadable: Yes)"},
            {"B_MRAP_01_hmg_F", 225000, "true", "The M-ATV is a four-wheel drive, all-terrain, MRAP-type vehicle. Primarily intended for use in counter-insurgency operations, it is multi-role and can act as both a troop carrier and supply vehicle if needed. (Slingload: No) (Slingloadable: Yes)"},
            {"O_MRAP_02_hmg_F", 225000, "true", "The Karatel is a four-wheel drive MRAP-type vehicle that can fulfil many roles ranging from serving as a V.I.P. transport, escort vehicle, light troop transport, to reconnaissance. All in a well-protected and compact package. (Slingload: No) (Slingloadable: Yes)"},
            {"I_MRAP_03_hmg_F", 225000, "true", "The Fennek is a four-wheel drive armed reconnaissance vehicle. Though its primary mission is observation, it can act as both a light troop transport and scout vehicle as well. (Slingload: No) (Slingloadable: Yes)"},
            {"B_MRAP_01_gmg_F", 250000, "true", "The M-ATV is a four-wheel drive, all-terrain, MRAP-type vehicle. Primarily intended for use in counter-insurgency operations, it is multi-role and can act as both a troop carrier and supply vehicle if needed. (Slingload: No) (Slingloadable: Yes)"},
            {"O_MRAP_02_gmg_F", 250000, "true", "The Karatel is a four-wheel drive MRAP-type vehicle that can fulfil many roles ranging from serving as a V.I.P. transport, escort vehicle, light troop transport, to reconnaissance. All in a well-protected and compact package. (Slingload: No) (Slingloadable: Yes)"},
            {"I_MRAP_03_gmg_F", 250000, "true", "The Fennek is a four-wheel drive armed reconnaissance vehicle. Though its primary mission is observation, it can act as both a light troop transport and scout vehicle as well. (Slingload: No) (Slingloadable: Yes)"}
        };
        spawnPoints[] =
        {
            {"Main Spawn",{"civilian_vehicles_spawn_1"}}
        };
    };

    class LAvehicles
    {
        displayName = "Light Armored Vehicles";
        vehicles[] =
        {
            {"I_LT_01_scout_F", 300000, "true", "The AWC 300 Nyx family consists of a number of light, fast and agile combat vehicles used by the AAF. While small and lightly armored, the Nyx can surprise enemies by striking from unexpected positions with its decent and accurate firepower. The anti-tank and air-defense variants are equipped with IR guided missiles and a 12.7mm HMG. The strike variant uses a 20mm autocannon and a 7.62mm coaxial machinegun. The recon variant is unarmed, but uses its radar and sensors to detect nearby threats and pass target data to friendly units via datalink. It can also paint targets with its laser designator, which is located on a telescopic mount. (Seating Capacity: 2)"},
            {"I_LT_01_AT_F", 350000, "true", "The AWC 300 Nyx family consists of a number of light, fast and agile combat vehicles used by the AAF. While small and lightly armored, the Nyx can surprise enemies by striking from unexpected positions with its decent and accurate firepower. The anti-tank and air-defense variants are equipped with IR guided missiles and a 12.7mm HMG. The strike variant uses a 20mm autocannon and a 7.62mm coaxial machinegun. The recon variant is unarmed, but uses its radar and sensors to detect nearby threats and pass target data to friendly units via datalink. It can also paint targets with its laser designator, which is located on a telescopic mount. (Seating Capacity: 2)"},
            {"I_LT_01_AA_F", 350000, "true", "The Wiesel 2 family consists of a number of light, fast and agile combat vehicles used by the AAF. While small and lightly armored, the Nyx can surprise enemies by striking from unexpected positions with its decent and accurate firepower. The anti-tank and air-defense variants are equipped with IR guided missiles and a 12.7mm HMG. The strike variant uses a 20mm autocannon and a 7.62mm coaxial machinegun. The recon variant is unarmed, but uses its radar and sensors to detect nearby threats and pass target data to friendly units via datalink. It can also paint targets with its laser designator, which is located on a telescopic mount. (Seating Capacity: 2)"},
            {"B_APC_Wheeled_03_cannon_F", 420000, "true", "The Gorgon is an 8x8 armoured combat vehicle that uses an inverted V-shape hull. It is designed to transport troops into battle and to provide fire support against a variety of ground threats. (Seating Capacity: 11)"},
            {"O_APC_Wheeled_02_rcws_v2_F", 420000, "true", "The Otokar ARMA is an amphibious 6-wheeled APC used by the OPFOR army. It's an agile and maneuverable vehicle with a low silhouette and compact size. Its reliability and maintenance costs match the western APCs. (Seating Capacity: 11)"},
            {"B_APC_Wheeled_01_cannon_F", 420000, "true", "The Badger IFV is an 8x8 infantry fighting vehicle designed as a medium-lift personnel carrier for expeditionary warfare. It can operate across a variety of environments ranging from land to sea, and can even be para-dropped from the air. (Seating Capacity: 11)"},
            {"B_AFV_Wheeled_01_cannon_F", 450000, "true", "The Rooikat 120 is the latest wheeled tank destroyer in NATO armored forces, designed for easy transportation to crisis regions. Its lightweight 120mm main cannon can use all conventional rounds including MARUK ATGMs, which increase its effective range to 8 km. The vehicle's secondary weapon is the .338 magnum SPMG coaxial machinegun. The price paid for the Rhino's great mobility and firepower is its light armor and low supplies of ammo and fuel. (Seating Capacity: 3)"},
            {"B_APC_Tracked_01_rcws_F", 440000, "true", "The Namer is a heavily-armoured troop carrier that is designed to be modular. Its chassis can be modified in order to be adapted for use in other roles, though its primary purpose remains transporting troops into or out of combat. (Seating Capacity: 11)"},
            {"O_APC_Tracked_02_cannon_F", 440000, "true", "The BM-2T Stalker is a highly manoeuvrable infantry fighting vehicle designed as a troop transport that can engage armoured ground and low-flying aerial targets while stationary, and as an armoured reconnaissance vehicle. (Seating Capacity: 11)"},
            {"O_APC_Tracked_02_AA_F", 440000, "true", "The ZSU-35 Tigris is a dedicated anti-aircraft variant of its IFV parent that is fitted with a turret armed with dual 35 mm cannons and surface-to-air missiles. (Seating Capacity: 3)"},
            {"I_APC_tracked_03_cannon_F", 440000, "true", "The FV-510 Warrior is an armoured vehicle used to transport infantry squads into combat under protection, and to provide fire support once troops have disembarked. It is fitted with a 30 mm cannon that is capable of firing both high-explosive and armour-piercing rounds at ranges of up to 1,500 metres against light-medium armoured vehicles. (Seating Capacity: 10)"},
            {"B_APC_Tracked_01_AA_F", 500000, "true", "Primarily used to defend against aerial threats, the Bardelas is fitted with a turret armed with dual 35 mm cannons and four surface-to-air missiles that can be fired in a rapid succession once an aerial target is locked onto. (Seating Capacity: 3)"}
        };
        spawnPoints[] =
        {
            {"Main Spawn",{"civilian_vehicles_spawn_1"}}
        };
    };

    class HAvehicles
    {
        displayName = "Heavy Armored Vehicles";
        vehicles[] =
        {
            {"I_MBT_03_cannon_F", 560000, "true", "The Leopard 2SG is the main battle tank used by Altian Armed Forces. A batch of a few dozen tanks and spare turrets were bought under-price from a South-European country facing economic collapse. Like similar MBTs of the era, the Kuma is armed with a 120mm cannon, 7.62mm coaxial machine gun and a remotely controlled 12.7mm HMG. The level of protection for the crew is also remarkable, thanks to additional armor layers. (Seating Capacity: 3)"},
            {"O_MBT_02_cannon_F", 575000, "true", "A modernized version of the Russian T-95 MBT. The ongoing development of the new generation battle tank was restarted in 2016 thanks to revenues from the oil crisis. The new concept of battle tank is lower, lighter with increased maneuverability. The crew was moved from the turret to a more armored body of the tank resulting in increased survivability. The T-100 Varsuk comes with a standard 125 mm cannon. (Seating Capacity: 3)"},
            {"B_MBT_01_cannon_F", 600000, "true", "The Merkava MK IV M is a main battle tank that uses a drive train consisting of six road wheels, one rear idler wheel, one front drive sprocket and three return rollers per side.The turret is triangular and narrow in shape, large but low, and is mounted rearwards onto the chassis, a layout commonly found on SPGs. (Seating Capacity: 9)"},
            {"O_MBT_04_cannon_F", 625000, "true", "A licensed variant of the original Russian design operated by the elite of CSAT armored forces. The tank is equipped with a high velocity, high-accuracy 125mm cannon, a 7.62mm coaxial machinegun, and a 12.7mm HMG in a remote turret. The crew is located in an armored capsule in the hull, improving survivability and eliminating one of the weaknesses of older tank designs. The disadvantage is its technical complexity and cost, resulting in low production numbers. (Seating Capacity: 3)"},
            {"B_MBT_01_TUSK_F", 650000, "true", "The Merkava MK IV LIC is the urban purpose variant of the M2A1 Slammer. Compared to the basic version, it features heavier armor with reinforced rear of the tank and a remote-controlled turret fitted with 12.7 mm heavy machine gun. (Seating Capacity: 9)"}
        };
        spawnPoints[] =
        {
            {"Main Spawn",{"civilian_vehicles_spawn_1"}}
        };
    };

    class AAvehicles
    {
        displayName = "Artillery Vehicles";
        vehicles[] =
        {
            {"I_Truck_02_MRL_F", 400000, "true", "The KamAZ MRL is simply a modified variant of the baseline Zamak truck that has had its rear flatbed configured to house a rocket pod. It is armed with a 230 mm rocket pod which is always pre-loaded with 12 long-range artillery rockets. (Seating Capacity: 3)"},
            {"B_MBT_01_mlrs_F", 600000, "true", "Sharing the same chassis as its MBT parent, the Seara is essentially a mobile rocket battery on treads. It can accurately deliver high-explosive rockets with a dispersion of less than 100 m on targets more than 11 km away in a single salvo. (Seating Capacity: 3)"},
            {"B_MBT_01_arty_F", 700000, "true", "Fitted with a 155 mm howitzer cannon as its primary weapon, the Scorcher is a powerful gun-based fire support vehicle that can launch a mixture of high-explosive, smoke, cluster, and even precision guided shells on targets at extreme distances. (Seating Capacity: 3)"}
        };
        spawnPoints[] =
        {
            {"Main Spawn",{"civilian_vehicles_spawn_1"}}
        };
    };

    class Avehicles
    {
        displayName = "Fixed-Wing and VTOL Aircraft";
        vehicles[] =
        {
            {"B_T_VTOL_01_armed_F", 420000, "true", "The Blackfish is a multi-mission tiltrotor aircraft that uses one three-bladed proprotor, turboprop engines fitted on the end of each wing, The V-44X Blackfish’s third-generation tilt-rotor VTOL (Vertical Take-Off and Landing) technology provides unparalleled maneuverability with its unique ability to perform pylon turns or merely hover in place, Armed variant of the Blackfish. Has two gunners who remotely operate its weapon systems through control panels in front of their seats.. (Slingload: No) (Slingloadable: No)"},
            {"I_C_Plane_Civil_01_F", 50000, "true", "The Cessna TTx is a single-engine, fixed-gear, low-wing general aviation aircraft built from composite materials. The Caesar BTT is one of the fastest fixed-gear, single-engine piston aircraft, reaching a speed of 235 knots (435 km/h) true air speed at 25,000 feet (7,600 m). It is used by civilians and smaller shipping companies all around the world. (Slingload: No) (Slingloadable: No)"},
            {"I_Plane_Fighter_04_F", 500000, "true", "The Gripen is a fourth-generation, single-seat, single-engine, and all-weather tactical fighter jet. The aircraft was designed as a multi-role platform at an affordable cost, and unlike some of the larger air-superiority jets, it can also perform well in low-altitude flight. Despite its aging platform, the A-149 has still been upgraded with the newest sensors and weapons systems. (Slingload: No) (Slingloadable: No)"},
            {"I_Plane_Fighter_03_dynamicLoadout_F", 600000, "true", "The Aero L 159 ALCA (Advanced Light Combat Aircraft) is a Czech-built single-seat light multi-role combat aircraft designed for a variety of air-to-air, air-to-ground and reconnaissance missions. The aircraft is equipped with a radar for all-weather, day and night operations. (Slingload: No) (Slingloadable: No)"},
            {"O_Plane_Fighter_02_F", 650000, "true", "The To-201 Shikra is a fifth-generation, single-seat, twin-engine, all-weather tactical fighter jet. The aircraft was designed by a CSAT and Russian joint syndicate with the goal to build a highly agile and maneuverable air-superiority fighter. (Slingload: No) (Slingloadable: No)"},
            {"B_Plane_Fighter_01_F", 650000, "true", "The Black Wasp is a twin-engined stealth fighter that uses a clipped delta wing design with a reverse sweep on the rear. (Slingload: No) (Slingloadable: No)"},
            {"O_Plane_CAS_02_dynamicLoadout_F", 650000, "true", "The Yak-130 is a new addition to CSAT air forces. An agile single-seat aircraft is used for close air support but can also take down air threats. It cannot carry as much payload as NATO's A-164 and has to rearm more often, but it can take-off from even the roughest terrain, not being as dependent on air bases or aircraft carriers. (Slingload: No) (Slingloadable: No)"},
            {"B_Plane_CAS_01_dynamicLoadout_F", 650000, "true", "The A-10D Thunderbolt II is a twin turbofan-engined, ground attack jet that uses a cantilever low-wing monoplane wing design with a wide chord. It is meant to be used exclusively for ground attack and close air support. (Slingload: No) (Slingloadable: No)"},
            {"O_Plane_Fighter_02_Stealth_F", 700000, "true", "The To-201 Shikra is a fifth-generation, single-seat, twin-engine, all-weather tactical fighter jet. The aircraft was designed by a CSAT and Russian joint syndicate with the goal to build a highly agile and maneuverable air-superiority fighter. (Slingload: No) (Slingloadable: No)"},
            {"B_Plane_Fighter_01_Stealth_F", 700000, "true", "The Black Wasp is a twin-engined stealth fighter that uses a clipped delta wing design with a reverse sweep on the rear. (Slingload: No) (Slingloadable: No)"}
        };
        spawnPoints[] =
        {
            {"Main Spawn",{"civilian_vehicles_spawn_1"}}
        };
    };

    class Hvehicles
    {
        displayName = "Rotary-Wing Aircraft";
        vehicles[] =
        {
            {"I_C_Heli_Light_01_civil_F", 50000, "true", "Comparable in size and appearance to NATO's MH-9, the MD 500 is the civilian variant of the same xH-9 series of light helicopters. (Slingload: Yes, up to 500 kg) (Slingloadable: No)"},
            {"B_Heli_Light_01_stripped_F", 75000, "true", "The Hummingbird is a five-bladed, single engine, rotary-wing light helicopter designed for both observation and light transport roles. (Slingload: Yes, up to 500 kg) (Slingloadable: No)"},
            {"B_Heli_Light_01_F", 150000, "true", "The Hummingbird is a five-bladed, single engine, rotary-wing light helicopter designed for both observation and light transport roles. (Slingload: Yes, up to 500 kg) (Slingloadable: No)"},
            {"B_Heli_Light_01_dynamicLoadout_F", 200000, "true", "The Pawnee is a five-bladed, single engine, rotary-wing light helicopter designed for both observation and light attack roles. Unlike the Hummingbird, the Pawnee has two stub wings located on either side of the fuselage where the side benches that support dynamic loadouts. (Slingload: Yes, up to 500 kg) (Slingloadable: No)"},
            {"I_Heli_light_03_unarmed_F", 200000, "true", "The Wildcat is a four-bladed, twin-engined rotary-wing helicopter that is capable of serving in many roles. These range from providing air-to-ground fire support as a light gunship, ferrying troops and cargo into battle as a utility transport, and even as an anti-tank/ship helicopter when outfitted with guided missiles. (Yes, up to 2000 kg) (Slingloadable: No)"},
            {"O_Heli_Light_02_unarmed_F", 200000, "true", "The Kasatka is a four-bladed, rotary-wing light helicopter with a fantail designed for both aerial reconnaissance and light transport duties. (Yes, up to 2000 kg) (Slingloadable: No)"},
            {"I_Heli_light_03_dynamicLoadout_F", 300000, "true", "The Wildcat is a four-bladed, twin-engined rotary-wing helicopter that is capable of serving in many roles. These range from providing air-to-ground fire support as a light gunship, ferrying troops and cargo into battle as a utility transport, and even as an anti-tank/ship helicopter when outfitted with guided missiles. (Yes, up to 2000 kg) (Slingloadable: No)"},
            {"O_Heli_Light_02_dynamicLoadout_F", 300000, "true", "The Kasatka is a four-bladed, rotary-wing light helicopter with a fantail designed for both aerial reconnaissance and light transport duties. (Yes, up to 2000 kg) (Slingloadable: No)"},
            {"B_Heli_Transport_01_F", 350000, "true", "The Ghost Hawk is a five-bladed, twin engine, rotary-wing stealth helicopter designed for slingloading cargo and to transport troops into battle. (Slingload: Yes, up to 4000 kg) (Slingloadable: No)"},
            {"I_Heli_Transport_02_F", 350000, "true", "The AW101 Merlin is a mobile spawn point. The Merlin is a conventionally designed, four-bladed, rotary-wing helicopter that is powered by three engines. (Slingload: Yes, up to 5000 kg) (Slingloadable: No)"},
            {"B_Heli_Transport_03_unarmed_green_F", 350000, "true", "The CH-67 Huron is a mobile spawn point. The Huron is a twin-engine, tandem rotor, semi-stealth heavy-lift helicopter. The tandem rotor layout eliminates the need for an anti-torque vertical rotor, allowing all power to be used for lift and thrust. This means it less sensitive to changes in its centre of gravity, making the Huron suitable for slingloading heavy cargo loads. (Slingload: Yes, up to 12000 kg) (Slingloadable: No)"},
            {"O_Heli_Transport_04_F", 350000, "true", "This is a Mi-290 Taru is a mobile spawn point. The Taru is a twin-engine, heavy-lift utility helicopter that uses a distinctive coaxial rotor system which removes the need for a tail rotor. It is unique for its ability to utilise interchangeable mission pods, which grant the Mi-290 a diverse array of performable roles, from transporting troops into battle, to providing air medical services. (Slingload: Yes, up to 13500 kg) (Slingloadable: No)"},
            {"B_Heli_Transport_03_F", 400000, "true", "The CH-67 Huron is a mobile spawn point. The Huron is a twin-engine, tandem rotor, semi-stealth heavy-lift helicopter. The tandem rotor layout eliminates the need for an anti-torque vertical rotor, allowing all power to be used for lift and thrust. This means it less sensitive to changes in its centre of gravity, making the Huron suitable for slingloading heavy cargo loads. (Slingload: Yes, up to 12000 kg) (Slingloadable: No)"},
            {"B_Heli_Attack_01_dynamicLoadout_F", 525000, "true", "The Comanchie is a five-bladed, rotary-wing stealth helicopter designed for both armed reconnaissance and ground attack duties.(Slingload: No) (Slingloadable: No)"},
            {"O_Heli_Attack_02_dynamicLoadout_F", 575000, "true", "The Mi-48 is a large helicopter gunship with low-capacity troop transport capability. It uses a tandem cockpit layout, and has a distinctive coaxial rotor system that removes the need for a tail rotor."}
        };
        spawnPoints[] =
        {
            {"Main Spawn",{"civilian_vehicles_spawn_1"}}
        };
    };

    class NDunits
    {
        displayName = "UAVs and UGVs (NATO)";
        vehicles[] =
        {
            {"B_UavTerminal", 10000, "true", "Use this Terminal to connect to NATO drones."},
            {"ACE_UAVBattery", 100, "true", "ACE UAV Battery"},
            {"B_UAV_01_F", 5000, "true", "Man portable and compact, the Darter is miniature VTOL-capable quad-rotor drone that is small enough to be carried in a backpack."},
            {"B_UAV_06_F", 5000, "true", "Compared to the Darter, the AL-6 Pelican Utility Drone's overall functionality is more simplistic as it is only designed with ferrying supplies in mind (usually medical items). Because it lacks a laser designator and does not possess a secondary camera with thermal/night vision capability, it is similarly ill-suited for use in a reconnaissance or surveillance role."},
            {"B_UAV_06_medical_F", 5000, "true", "Compared to the Darter, the AL-6 Pelican Utility Drone's overall functionality is more simplistic as it is only designed with ferrying supplies in mind (usually medical items). Because it lacks a laser designator and does not possess a secondary camera with thermal/night vision capability, it is similarly ill-suited for use in a reconnaissance or surveillance role."},
            {"B_UAV_02_dynamicLoadout_F", 500000, "true", "The YABHON is a medium-altitude, long-endurance aerial drone that can serve a variety of roles from surveillance to ground attack, and even air-to-air combat. (Slingload: No) (Slingloadable: Yes)"},
            {"B_UAV_05_F", 500000, "true", "The Sentinel is a tailless, jet-powered stealth drone that uses a blended-wing-body airframe. It is designed primarily to be used for both ground attack and close air support roles. (Slingload: No) (Slingloadable: Yes)"},
            {"B_UGV_02_Science_F", 5000, "true", "ED-1 is a commercial off-the-shelf series of robotic systems built upon a man-portable modular platform. The tracked mini UGV has convenient front and rear obstacle climbers that allow it to traverse relatively complex terrain. (Slingload: No) (Slingloadable: Yes)"},
            {"B_UGV_02_Demining_F", 10000, "true", "ED-1 is a commercial off-the-shelf series of robotic systems built upon a man-portable modular platform. The tracked mini UGV has convenient front and rear obstacle climbers that allow it to traverse relatively complex terrain. (Slingload: No) (Slingloadable: Yes)"},
            {"B_UGV_01_F", 10000, "true", "The Stomper is available in two variants; an unarmed version that has no weapons mounted on it that is meant to be used for transporting supplies and cargo, and an armed version that is fitted with an RCWS turret armed with a dual-mount 12.7 mm heavy machine gun and 40 mm automatic grenade launcher. (Slingload: No) (Slingloadable: Yes)"},
            {"B_UGV_01_rcws_F", 50000, "true", "The Stomper is available in two variants; an unarmed version that has no weapons mounted on it that is meant to be used for transporting supplies and cargo, and an armed version that is fitted with an RCWS turret armed with a dual-mount 12.7 mm heavy machine gun and 40 mm automatic grenade launcher. (Slingload: No) (Slingloadable: Yes)"},
            {"B_T_UAV_03_dynamicLoadout_F", 100000, "true", "The Falcon is a single engine, five-bladed, long-endurance helicopter UAV. Designed as a semi-stealthed VTOL drone, the Falcon has the ability to autonomously take off and land on any prepared and unprepared surface. (Slingload: No) (Slingloadable: No)"}
        };
        spawnPoints[] =
        {
            {"Main Spawn",{"civilian_vehicles_spawn_1"}}
        };
    };

    class IDunits
    {
        displayName = "UAVs and UGVs (Independent)";
        vehicles[] =
        {
            {"I_UavTerminal", 10000, "true", "Use this Terminal to connect to INDEPENDANT drones."},
            {"ACE_UAVBattery", 100, "true", "ACE UAV Battery"},
            {"I_UAV_01_F", 5000, "true", "Man portable and compact, the Darter is miniature VTOL-capable quad-rotor drone that is small enough to be carried in a backpack."},
            {"I_UAV_06_F", 5000, "true", "Compared to the Darter, the AL-6 Pelican Utility Drone's overall functionality is more simplistic as it is only designed with ferrying supplies in mind (usually medical items). Because it lacks a laser designator and does not possess a secondary camera with thermal/night vision capability, it is similarly ill-suited for use in a reconnaissance or surveillance role."},
            {"I_UAV_06_medical_F", 5000, "true", "Compared to the Darter, the AL-6 Pelican Utility Drone's overall functionality is more simplistic as it is only designed with ferrying supplies in mind (usually medical items). Because it lacks a laser designator and does not possess a secondary camera with thermal/night vision capability, it is similarly ill-suited for use in a reconnaissance or surveillance role."},
            {"I_UAV_02_dynamicLoadout_F", 500000, "true", "The K40 Ababil-3 is a medium-altitude, long-endurance aerial drone that can serve a variety of roles from surveillance to ground attack, and even air-to-air combat. (Slingload: No) (Slingloadable: Yes)"},
            {"I_UGV_02_Science_F", 5000, "true", "ED-1 is a commercial off-the-shelf series of robotic systems built upon a man-portable modular platform. The tracked mini UGV has convenient front and rear obstacle climbers that allow it to traverse relatively complex terrain. (Slingload: No) (Slingloadable: Yes)"},
            {"I_UGV_02_Demining_F", 10000, "true", "ED-1 is a commercial off-the-shelf series of robotic systems built upon a man-portable modular platform. The tracked mini UGV has convenient front and rear obstacle climbers that allow it to traverse relatively complex terrain. (Slingload: No) (Slingloadable: Yes)"},
            {"I_E_UGV_01_F", 10000, "true", "The Stomper is available in two variants; an unarmed version that has no weapons mounted on it that is meant to be used for transporting supplies and cargo, and an armed version that is fitted with an RCWS turret armed with a dual-mount 12.7 mm heavy machine gun and 40 mm automatic grenade launcher. (Slingload: No) (Slingloadable: Yes)"},
            {"I_E_UGV_01_rcws_F", 50000, "true", "The Stomper is available in two variants; an unarmed version that has no weapons mounted on it that is meant to be used for transporting supplies and cargo, and an armed version that is fitted with an RCWS turret armed with a dual-mount 12.7 mm heavy machine gun and 40 mm automatic grenade launcher. (Slingload: No) (Slingloadable: Yes)"}
        };
        spawnPoints[] =
        {
            {"Main Spawn",{"civilian_vehicles_spawn_1"}}
        };
    };
};
