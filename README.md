# **cdss-ruby**


[![Build Status](https://github.com/mgm702/cdss-ruby/actions/workflows/main.yml/badge.svg)](https://github.com/mgm702/cdss-ruby/actions)
[![Gem Version](https://badge.fury.io/rb/cdss-ruby.svg)](https://badge.fury.io/rb/cdss-ruby)
[![MIT license](https://img.shields.io/badge/license-MIT-brightgreen.svg)](https://opensource.org/licenses/MIT)

[**« CDSS »**](https://dwr.state.co.us/Tools)

[**CDSS REST Web**](https://dwr.state.co.us/Rest/GET/Help)


The goal of [**`cdss-ruby`**](https://rubygems.org/gems/cdss-ruby) is to provide functions that help Ruby users to navigate, explore, and make requests to the CDSS REST API web service. 

The Colorado's Decision Support Systems (CDSS) is a water management system created and developed by the Colorado Water Conservation Board (CWCB) and the Colorado Division of Water Resources (DWR).

Thank you to those at CWCB and DWR for providing an accessible and well documented REST API!


> See [**`cdssr`**](https://github.com/anguswg-ucsb/cdssr), for the **R** version of this package

> See [**`cdsspy`**](https://github.com/anguswg-ucsb/cdsspy), for the **Python** version of this package

---

- [**cdssr (R)**](https://github.com/anguswg-ucsb/cdssr)

- [**cdssr documentation**](https://anguswg-ucsb.github.io/cdssr/)

- [**cdsspy (Python)**](https://github.com/anguswg-ucsb/cdsspy)

- [**cdsspy documentation**](https://pypi.org/project/cdsspy/)

- [**cdss-ruby (Ruby)**](https://github.com/mgm702/cdss-ruby)

- [**cdss-ruby documentation**](https://mgm702.com/cdss-ruby/)

---



## **Installation**

Add this line to your application's Gemfile:

```ruby
gem 'cdss-ruby'
```
and then execute
```ruby
bundle install
```

or install it yourself as:
```bash
gem install cdss-ruby
```

## **Getting Started**

Using the gem is simple. Create a client and start making requests:

```ruby
irb(main):001:0> @client = Cdss.client
=> #<Cdss::Client:0x0000000103f757c0 @api_key=nil, @options={}>
irb(main):002:0> @client.get_sw_stations
```

## **Available Endpoints**

The `cdss-ruby` gem provides access to all CDSS API endpoints through an intuitive interface. For detailed documentation on each endpoint and its methods, please visit our [documentation site](https://mgm702.com/cdss-ruby).
Here are some key modules:

* [Cdss::AdminCalls](https://mgm702.com/cdss-ruby/Cdss/AdminCalls.html) - Access administrative calls and structure data
* [Cdss::Climate](https://mgm702.com/cdss-ruby/Cdss/Climate.html) - Get climate station data and time series
* [Cdss::Groundwater](https://mgm702.com/cdss-ruby/Cdss/GroundWater.html) - Access groundwater well data and measurements
* [Cdss::ReferenceTables](https://mgm702.com/cdss-ruby/Cdss/ReferenceTables.html) - Get reference tables
* [Cdss::SurfaceWater](https://mgm702.com/cdss-ruby/Cdss/SurfaceWater.html) - Access surface water stations and time series
* [Cdss::Telemetry](https://mgm702.com/cdss-ruby/Cdss/Telemetry.html) - Get telemetry station data and time series
* [Cdss::WaterRights](https://mgm702.com/cdss-ruby/Cdss/WaterRights.html) - Access water rights net amounts and transactions
* [Cdss::Analysis](https://mgm702.com/cdss-ruby/Cdss/Analysis.html) - Perform call analysis and get source route frameworks

## **Development**

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

If you would like to contribute to this plugin, submit a Pull Request with an excellent commit message. 
Contributions are more then welcome, however please make sure that your commit message is clear and understandable. 

## License

The cdss-ruby gem is licensed under the MIT license.

## Like The Gem?

If you like Tabtastic.vim follow the repository on [Github](https://github.com/mgm702/vim-tabtastic) and if you are feeling extra nice, follow the author [mgm702](http://mgm702.com) on [Twitter](https://twitter.com/mgm702) or [Github](https://github.com/mgm702).

