# Disable rules at the Edge, these will be handled by the App Gateway WAF as
# AFD has a 100-exclusion limit due to Global Propagation
waf_managed_rulesets = {
  "Microsoft_DefaultRuleSet_2.1" = {
    action = "Block"
    overrides = {
      "SQLI" = {
        disabled_rules = [
          "942100", "942110", "942150", "942180", "942200", "942210",
          "942230", "942260", "942310", "942340", "942360", "942370", "942380",
          "942390", "942400", "942410", "942430", "942440", "942450", "942480"
        ]
      },
      "XSS" = {
        disabled_rules = ["941100", "941120", "941150", "941330"]
      },
      "RFI" = {
        disabled_rules = ["931130"]
      },
      "MS-ThreatIntel-SQLI" = {
        disabled_rules = ["99031001", "99031002", "99031003", "99031004"]
      },
      "PHP" = {
        disabled_rules = ["933160", "933210"]
      },
      "PROTOCOL-ENFORCEMENT" = {
        disabled_rules = ["920230", "920300", "920320", "920440"]
      },
      "PROTOCOL-ATTACK" = {
        disabled_rules = ["921110"]
      },
      "RCE" = {
        disabled_rules = ["932100", "932105", "932110", "932115", "932150"]
      }
    }
  },
  "Microsoft_BotManagerRuleSet_1.1" = {
    action    = "Block"
    overrides = {}
  }
}
