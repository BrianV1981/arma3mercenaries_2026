// arma3mercenaries\sector_control\cba_settings.hpp

class CfgSettings {
    class CBA {
        class arma3mercenaries { // Main Addon category

            // Sector Control Settings Category
            class sectorControlSettings {
                title = "arma3mercenaries Sector Control Settings"; // Main title for this section

                // --- Global Settings Sub-Category ---
                class globalSectorSettings {
                    title = "Global Sector Settings"; // Title for the global subsection
                    description = "Settings that apply generally to the sector control system.";

                    class global_checkInterval {
                        title = "Position Check Interval (Seconds)";
                        description = "How often (in seconds) the script checks if a player is inside/outside a captured sector. Affects how quickly 'strikes' accumulate.";
                        typeName = "NUMBER";
                        value = 120; // Default: 2 minutes
                        values[] = {10, 600}; // Min: 10 seconds, Max: 10 minutes
                    };
                    class global_maxRewards {
                        title = "Rewards Before Completion Block";
                        description = "How many reward payouts a player receives before being blocked from the sector (normal completion).";
                        typeName = "NUMBER";
                        value = 6; // Default: 6 rewards
                        values[] = {1, 20}; // Min: 1 reward, Max: 20 rewards
                    };
                     class global_maxStrikes {
                        title = "Strikes Before Strikeout Block";
                        description = "How many consecutive position checks must fail (player outside) before they are blocked for leaving.";
                        typeName = "NUMBER";
                        value = 3; // Default: 3 strikes
                        values[] = {1, 10}; // Min: 1 strike, Max: 10 strikes
                    };
                    class global_mainLoopSleep {
                         title = "Main Loop Scan Interval (Seconds)";
                         description = "How often (in seconds) the main server loop scans all sector triggers for players to initiate the monitoring process.";
                         typeName = "NUMBER";
                         value = 120; // Default: 2 minutes
                         values[] = {30, 600}; // Min: 30 seconds, Max: 10 minutes
                    };
                }; // End Global Settings

                // --- Per-Sector Settings (Generated via Loop in SQF, but defined structurally here) ---
                // We define one example structure, the SQF will generate all 12

                class sector1Settings { // Example structure for Sector 1
                    title = "Sector 1: Fort MAGA Settings"; // Title generated dynamically

                    class sector1_rewardMultiplier {
                        title = "Reward Multiplier";
                        description = "Adjusts the base reward amounts for this specific sector (e.g., 0.5 = half reward, 2.0 = double reward).";
                        typeName = "NUMBER";
                        value = 0.5; // Default from your array
                        values[] = {0.0, 5.0}; // Range 0x to 5x
                    };
                    class sector1_spawnProbability {
                        title = "Enemy Spawn Probability Multiplier";
                        description = "Adjusts the chance of enemy groups spawning during the reward cycle for this sector (0 = never, 1 = default chance, 2 = double chance).";
                        typeName = "NUMBER";
                        value = 0.0; // Default from your array
                        values[] = {0.0, 3.0}; // Range 0x to 3x
                    };
                     class sector1_blockTime {
                        title = "Block Duration (Seconds)";
                        description = "How long (in seconds) a player is blocked from this sector after completing rewards or being struck out.";
                        typeName = "NUMBER";
                        value = 7200; // Default from your array (2 hours)
                        values[] = {60, 28800}; // Range 1 minute to 8 hours
                    };
                    class sector1_rewardTime {
                        title = "Reward Grant Interval (Seconds)";
                        description = "How often (in seconds) a reward payout is actually given to the player (if they are inside the sector).";
                        typeName = "NUMBER";
                        value = 720; // Default from your array (12 minutes)
                        values[] = {60, 3600}; // Range 1 minute to 1 hour
                    };
                }; // End Example Sector 1 Settings

                 // --- Add placeholders or actual definitions for Sector 2 through 12 ---
                 // The SQF will handle the real registration, but defining them here helps tools/intellisense if used.
                 // You can copy/paste the structure above and change the 'sector1' prefix and defaults accordingly for sectors 2-12.
                 // Or just leave it with Sector 1 as the template example for the HPP. The SQF is the most critical part.

                 class sector2Settings { title = "Sector 2: Paros Settings"; class sector2_rewardMultiplier { value=1.5; }; class sector2_spawnProbability { value=0.5; }; class sector2_blockTime { value=7200; }; class sector2_rewardTime { value=720; }; };
                 class sector3Settings { title = "Sector 3: Pefkas Military Base Settings"; class sector3_rewardMultiplier { value=1.25; }; class sector3_spawnProbability { value=0.25; }; class sector3_blockTime { value=7200; }; class sector3_rewardTime { value=720; }; };
                 class sector4Settings { title = "Sector 4: Pyrgos Settings"; class sector4_rewardMultiplier { value=2.0; }; class sector4_spawnProbability { value=1.0; }; class sector4_blockTime { value=10800; }; class sector4_rewardTime { value=720; }; };
                 class sector5Settings { title = "Sector 5: Charkia Settings"; class sector5_rewardMultiplier { value=1.5; }; class sector5_spawnProbability { value=1.0; }; class sector5_blockTime { value=7200; }; class sector5_rewardTime { value=720; }; };
                 class sector6Settings { title = "Sector 6: Anthrakia Settings"; class sector6_rewardMultiplier { value=1.75; }; class sector6_spawnProbability { value=1.25; }; class sector6_blockTime { value=9000; }; class sector6_rewardTime { value=720; }; };
                 class sector7Settings { title = "Sector 7: Neochori Settings"; class sector7_rewardMultiplier { value=1.25; }; class sector7_spawnProbability { value=1.0; }; class sector7_blockTime { value=7200; }; class sector7_rewardTime { value=720; }; };
                 class sector8Settings { title = "Sector 8: Athira Settings"; class sector8_rewardMultiplier { value=1.5; }; class sector8_spawnProbability { value=1.0; }; class sector8_blockTime { value=7200; }; class sector8_rewardTime { value=720; }; };
                 class sector9Settings { title = "Sector 9: Lakka Military Base Settings"; class sector9_rewardMultiplier { value=1.75; }; class sector9_spawnProbability { value=1.25; }; class sector9_blockTime { value=9000; }; class sector9_rewardTime { value=720; }; };
                 class sector10Settings { title = "Sector 10: Rodopoli Settings"; class sector10_rewardMultiplier { value=1.5; }; class sector10_spawnProbability { value=1.25; }; class sector10_blockTime { value=7200; }; class sector10_rewardTime { value=720; }; };
                 class sector11Settings { title = "Sector 11: Telos Military Base Settings"; class sector11_rewardMultiplier { value=2.0; }; class sector11_spawnProbability { value=1.75; }; class sector11_blockTime { value=10800; }; class sector11_rewardTime { value=720; }; };
                 class sector12Settings { title = "Sector 12: Gravia Airforce Base Settings"; class sector12_rewardMultiplier { value=3.0; }; class sector12_spawnProbability { value=1.9; }; class sector12_blockTime { value=14400; }; class sector12_rewardTime { value=720; }; };

            }; // End Sector Control Settings
        }; // End arma3mercenaries
    }; // End CBA
}; // End CfgSettings