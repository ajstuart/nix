{ desktop, hostname, lib, pkgs, username, ... }:
let
  defaultDns = [ "1.1.1.1" "1.0.0.1" ];
  # https://nixos.wiki/wiki/Steam
  isGamestation = if (hostname == "phasma" || hostname == "vader") && (desktop != null) then true else false;
  isInstall = if (builtins.substring 0 4 hostname != "iso-") then true else false;
  hasRazerPeripherals = if (hostname == "phasma" || hostname == "vader") then true else false;
  needsLowLatencyPipewire = if (hostname == "phasma" || hostname == "vader") then true else false;
  saveBattery = if (hostname != "phasma" && hostname != "vader") then true else false;

  # Define DNS settings for specific users
  # - https://cleanbrowsing.org/filters/
  userDnsSettings = {
    # Security Filter:
    # - Blocks access to phishing, spam, malware and malicious domains.
    martin = [ "185.228.168.9" "185.228.169.9" ];

    # Adult Filter:
    # - Blocks access to all adult, pornographic and explicit sites.
    # - It does not block proxy or VPNs, nor mixed-content sites.
    # - Sites like Reddit are allowed.
    # - Google and Bing are set to the Safe Mode.
    # - Malicious and Phishing domains are blocked.
    louise = [ "185.228.168.10" "185.228.169.11" ];

    # Family Filter:
    # - Blocks access to all adult, pornographic and explicit sites.
    # - It also blocks proxy and VPN domains that are used to bypass the filters.
    # - Mixed content sites (like Reddit) are also blocked.
    # - Google, Bing and Youtube are set to the Safe Mode.
    # - Malicious and Phishing domains are blocked.
    agatha = [ "185.228.168.168" "185.228.169.168" ];
  };
in
{
  imports = lib.optional (builtins.pathExists (./. + "/${desktop}")) ./${desktop};

  boot = {
    # Enable the threadirqs kernel parameter to reduce audio latency
    # - Inpired by: https://github.com/musnix/musnix/blob/master/modules/base.nix#L56
    kernelParams = [ "quiet" "vt.global_cursor_default=0" "mitigations=off" "threadirqs" ];
    plymouth = {
      enable = true;
    };
  };


  environment.systemPackages = with pkgs; lib.optionals (isInstall) [
    appimage-run
    (chromium.override { enableWideVine = true; })
    #pavucontrol
    #pulseaudio
    wmctrl
    xdotool
    ydotool
  ] ++ lib.optionals (isGamestation) [
    mangohud
  ] ++ lib.optionals (isInstall && hasRazerPeripherals) [
    polychromatic
  ];

  fonts = {
    # Enable a basic set of fonts providing several font styles and families and reasonable coverage of Unicode.
    enableDefaultPackages = false;
    fontDir.enable = true;
    packages = with pkgs; [
      (nerdfonts.override { fonts = [ "FiraCode" "NerdFontsSymbolsOnly" ]; })
      fira
      liberation_ttf
      noto-fonts-emoji
      source-serif
      twitter-color-emoji
      work-sans
    ] ++ lib.optionals (isInstall) [
      ubuntu_font_family
    ];

    fontconfig = {
      antialias = true;
      cache32Bit = isGamestation;
      defaultFonts = {
        serif = [ "Source Serif" ];
        sansSerif = [ "Work Sans" "Fira Sans" ];
        monospace = [ "FiraCode Nerd Font Mono" "Symbols Nerd Font Mono" ];
        emoji = [ "Noto Color Emoji" "Twitter Color Emoji" ];
      };
      enable = true;
      hinting = {
        autohint = false;
        enable = true;
        style = "slight";
      };
      subpixel = {
        rgba = "rgb";
        lcdfilter = "light";
      };
    };
  };

  networking = {
    networkmanager = {
       dns = "systemd-resolved";
      enable = true;
      # Conditionally set Public DNS based on username, defaulting if user not matched
      insertNameservers = if builtins.hasAttr username userDnsSettings then
                            userDnsSettings.${username}
                          else
                            defaultDns;
      wifi = {
        backend = "iwd";
        powersave = saveBattery;
      };
    };
  };

  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = isGamestation;
    };
    openrazer = lib.mkIf (hasRazerPeripherals) {
      enable = true;
      devicesOffOnScreensaver = false;
      keyStatistics = true;
      mouseBatteryNotifier = true;
      syncEffectsEnabled = true;
      users = [ "${username}" ];
    };
    pulseaudio.enable = lib.mkForce false;
    sane = lib.mkIf (isInstall) {
      enable = true;
      #extraBackends = with pkgs; [ hplipWithPlugin sane-airscan ];
      extraBackends = with pkgs; [ sane-airscan ];
    };
  };

  programs = {
    appimage.binfmt = true;
    chromium = {
      # Configures policies for Chromium, Chrome and Brave
      # - https://help.kagi.com/kagi/getting-started/setting-default.html
      # - https://chromeenterprise.google/policies/
      # - chromium.enable just enables the Chromium policies.
      enable = isInstall;
      extraOpts = {
        # Misc; privacy and data collection prevention
        "BrowserNetworkTimeQueriesEnabled" = false;
        "DeviceMetricsReportingEnabled" = false;
        "DomainReliabilityAllowed" = false;
        "FeedbackSurveysEnabled" = false;
        "MetricsReportingEnabled" = false;
        "SpellCheckServiceEnabled" = false;
        # Misc; DNS
        "BuiltInDnsClientEnabled" = false;
        # Misc; Tabs
        "NTPCardsVisible" = false;
        "NTPCustomBackgroundEnabled" = false;
        "NTPMiddleSlotAnnouncementVisible" = false;
        # Misc; Downloads
        "DefaultDownloadDirectory" = "/home/${username}/Downloads";
        "DownloadDirectory" = "/home/${username}/Downloads";
        "PromptForDownloadLocation" = false;
        # Misc
        "AllowSystemNotifications" = true;
        "AutofillAddressEnabled" = false;
        "AutofillCreditCardEnabled" = false;
        "BackgroundModeEnabled" = false;
        "BookmarkBarEnabled" = false;
        "BrowserAddPersonEnabled" = true;
        "BrowserLabsEnabled" = false;
        "PromotionalTabsEnabled" = false;
        "ShoppingListEnabled" = false;
        "ShowFullUrlsInAddressBar" = true;
        "SpellcheckEnabled" = true;
        "SpellcheckLanguage" = [
          "en-GB"
          "en-US"
        ];
        # Cloud Reporting
        "CloudReportingEnabled" = false;
        "CloudProfileReportingEnabled" = false;
        # Content settings
        "DefaultGeolocationSetting" = 3;
        "DefaultImagesSetting" = 1;
        "DefaultPopupsSetting" = 1;
        # Default search provider; Kagi
        "DefaultSearchProviderAlternateURLs" = [
          "https://kagi.com/search?q={searchTerms}"
        ];
        "DefaultSearchProviderEnabled" = true;
        "DefaultSearchProviderImageURL" = "https://assets.kagi.com/v2/apple-touch-icon.png";
        "DefaultSearchProviderKeyword" = "kagi";
        "DefaultSearchProviderName" = "Kagi";
        "DefaultSearchProviderSearchURL" = "https://kagi.com/search?q={searchTerms}";
        "DefaultSearchProviderSuggestURL" = "https://kagi.com/api/autosuggest?q={searchTerms}";
        # Generative AI; these settings disable the AI features to prevent data collection
        "CreateThemesSettings" = 2;
        "DevToolsGenAiSettings" = 2;
        "GenAILocalFoundationalModelSettings" = 1;
        "HelpMeWriteSettings" = 2;
        "TabOrganizerSettings" = 2;
        # Network
        "ZstdContentEncodingEnabled" = true;
        # Password manager
        "PasswordDismissCompromisedAlertEnabled" = true;
        "PasswordLeakDetectionEnabled" = false;
        "PasswordManagerEnabled" = false;
        "PasswordSharingEnabled" = false;
        # Printing
        #"PrintingPaperSizeDefault" = "iso_a4_210x297mm";
        # Related Website Sets
        "RelatedWebsiteSetsEnabled" = false;
        # Safe Browsing
        "SafeBrowsingExtendedReportingEnabled" = false;
        "SafeBrowsingProtectionLevel" = 1;
        "SafeBrowsingProxiedRealTimeChecksAllowed" = false;
        "SafeBrowsingSurveysEnabled" = false;
        # Startup, Home and New Tab Page
        "HomePageIsNewTabPage" = true;
        "HomePageLocation" = "https://${hostname}.drongo-gamma.ts.net";
        "NewTabPageLocation" = "https://${hostname}.drongo-gamma.ts.net";
        "RestoreOnStartup" = 1;
        "ShowHomeButton" = false;
      };
    };
    # TODO: Configure Microsoft Edge policy
    # - https://learn.microsoft.com/en-us/deployedge/microsoft-edge-policies
    # - https://github.com/M86xKC/edge-config/blob/main/policies.json

    # - https://mozilla.github.io/policy-templates/
    firefox = {
      enable = true;
      languagePacks = [ "en-GB" "en-US" ];
      package = pkgs.firefox;
      preferences = {
        "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;
        "browser.crashReports.unsubmittedCheck.enabled" = false;
        "browser.fixup.dns_first_for_single_words" =  false;
        "browser.newtab.extensionControlled" = true;
        "browser.search.update" = true;
        "browser.tabs.crashReporting.sendReport" = false;
        "browser.urlbar.suggest.bookmark" = false;
        "browser.urlbar.suggest.history" = true;
        "browser.urlbar.suggest.openpage" = false;
        "browser.tabs.warnOnClose" = false;
        "browser.urlbar.update2.engineAliasRefresh" = true;
        "datareporting.policy.dataSubmissionPolicyBypassNotification" = true;
        "dom.disable_window_flip" = true;
        "dom.disable_window_move_resize" = false;
        "dom.event.contextmenu.enabled" = true;
        "dom.reporting.crash.enabled" = false;
        "extensions.getAddons.showPane" = false;
        "media.gmp-gmpopenh264.enabled" = true;
        "media.gmp-widevinecdm.enabled" = true;
        "places.history.enabled" = true;
        "security.ssl.errorReporting.enabled" = false;
        "widget.use-xdg-desktop-portal.file-picker" = 1;
      };
      preferencesStatus = "default";
      policies = {
        "AutofillAddressEnabled" = false;
        "AutofillCreditCardEnabled" = false;
        "CaptivePortal" = true;
        "Cookies" = {
          "AcceptThirdParty" = "from-visited";
          "Behavior" = "reject-tracker";
          "BehaviorPrivateBrowsing" = "reject-tracker";
          "RejectTracker" = true;
        };
        "DisableAppUpdate" = true;
        "DisableDefaultBrowserAgent" = true;
        "DisableFirefoxStudies" = true;
        "DisableFormHistory" = true;
        "DisablePocket" = true;
        "DisableProfileImport" = true;
        "DisableTelemetry" = true;
        "DisableSetDesktopBackground" = true;
        "DisplayBookmarksToolbar" = "never";
        "DisplayMenuBar" = "default-off";
        "DNSOverHTTPS" = {
          "Enabled" = false;
        };
        "DontCheckDefaultBrowser" = true;
        "EnableTrackingProtection" = {
          "Value" = false;
          "Locked" = false;
          "Cryptomining" = true;
          "EmailTracking" = true;
          "Fingerprinting" = true;
        };
        "EncryptedMediaExtensions" = {
          "Enabled" = true;
          "Locked" = true;
        };
        # Check about:support for extension/add-on ID strings.
        ExtensionSettings = {
          "uBlock0@raymondhill.net" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            installation_mode = "force_installed";
          };
          "support@lastpass.com" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/lastpass-password-manager/latest.xpi";
            installation_mode = "force_installed";
          };
          "87677a2c52b84ad3a151a4a72f5bd3c4@jetpack" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/grammarly-1/latest.xpi";
            installation_mode = "force_installed";
          };
          "gdpr@cavi.au.dk" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/consent-o-matic/latest.xpi";
            installation_mode = "force_installed";
          };
          "sponsorBlocker@ajay.app" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
            installation_mode = "force_installed";
          };
          "{762f9885-5a13-4abd-9c77-433dcd38b8fd}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/return-youtube-dislikes/latest.xpi";
            installation_mode = "force_installed";
          };
          "easyscreenshot@mozillaonline.com" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/easyscreenshot/latest.xpi";
            installation_mode = "force_installed";
          };
          "search@kagi.com" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/kagi-search-for-firefox/latest.xpi";
            installation_mode = "force_installed";
          };
          "newtaboverride@agenedia.com" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/new-tab-override/latest.xpi";
            installation_mode = "force_installed";
          };
          "enterprise-policy-generator@agenedia.com" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/enterprise-policy-generator/latest.xpi";
            installation_mode = "force_installed";
          };
        };
        "ExtensionUpdate" = true;
        "FirefoxHome" = {
          "Search" = true ;
          "TopSites" = false;
          "SponsoredTopSites" = false;
          "Highlights" = false;
          "Pocket" = false;
          "SponsoredPocket" = false;
          "Snippets" = false;
          "Locked" = true;
        };
        "FirefoxSuggest" = {
          "WebSuggestions" = false;
          "SponsoredSuggestions" = false;
          "ImproveSuggest" = false;
          "Locked" = true;
        };
        "FlashPlugin" = {
          "Default" = false;
        };
        "HardwareAcceleration" = true;
        "Homepage" = {
          "Locked" = false;
          "StartPage" = "previous-session";
          "URL" = "https://${hostname}.drongo-gamma.ts.net";
        };
        "NetworkPrediction" = false;
        "NewTabPage" = true;
        "NoDefaultBookmarks" = true;
        "OfferToSaveLogins" = false;
        "OverrideFirstRunPage" = "";
        "OverridePostUpdatePage" = "";
        "PasswordManagerEnabled" = false;
        "PopupBlocking" = {
          "Default" = true;
        };
        "PromptForDownloadLocation" = false;
        "SearchBar" = "unified";
        "SearchEngines" = {
          "Add" = [
            {
              "Description" = "Kagi";
              "IconURL" = "https://assets.kagi.com/v2/apple-touch-icon.png";
              "Method" = "GET";
              "Name" = "Kagi";
              "SuggestURLTemplate" = "https://kagi.com/api/autosuggest?q={searchTerms}";
              "URLTemplate" = "https://kagi.com/search?q={searchTerms}";
            }
          ];
          "Default" = "Kagi";
          "DefaultPrivate" = "Kagi";
          "Remove" = [
            "Bing"
            "eBay"
            "Google"
          ];
        };
        "SearchSuggestEnabled" = true;
        "ShowHomeButton" = false;
        "StartDownloadsInTempDirectory" = true;
        "UserMessaging" = {
          "WhatsNew" = false;
          "ExtensionRecommendations" = true;
          "FeatureRecommendations" = false;
          "UrlbarInterventions" = false;
          "SkipOnboarding" = true;
          "MoreFromMozilla" = false;
          "Locked" = false;
        };
        "UseSystemPrintDialog" = true;
      };
    };
    steam = lib.mkIf (isGamestation) {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    };
    system-config-printer = lib.mkIf (isInstall) {
      enable = if (desktop == "mate") then true else false;
    };
  };

 
     # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;
    wireplumber.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };
  }