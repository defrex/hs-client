
dep.provide 'hs.globalTemplates'

dep.require 'hs.t.TopBar'
dep.require 'hs.t.Notifications'
dep.require 'hs.t.Loading'
dep.require 'hs.t.Nav'

hs.globalTemplates = [
  hs.t.TopBar,
  hs.t.Notifications,
  hs.t.Loading,
  hs.t.Nav,
  #hs.t.NewListing,
]
