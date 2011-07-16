
dep.require 'hs'
dep.provide 'hs.urls'

dep.require 'hs.t.Listing'
dep.require 'hs.t.About'
dep.require 'hs.t.HowItWorks'
dep.require 'hs.t.NameSetting'
dep.require 'hs.t.SocialSetting'

hs.urls =
  '^/(listing/\\d+)/?': hs.t.Listing
  '^/about/?': hs.t.About
  '^/how-it-works/?': hs.t.HowItWorks
  '^/settings/name/?': hs.t.NameSetting
  '^/settings/password/?': hs.t.PasswordSetting
  '^/settings/social/?': hs.t.SocialSetting
