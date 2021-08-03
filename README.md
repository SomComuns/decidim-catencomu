# catencomu

Free Open-Source participatory democracy, citizen participation and open government for cities and organizations

This is the open-source repository for catencomu, based on [Decidim](https://github.com/decidim/decidim).

## Setting up the application

You will need to do some steps before having the app working properly once you've deployed it:

1. Open a Rails console in the server: `bundle exec rails console`
2. Create a System Admin user:

```ruby
user = Decidim::System::Admin.new(email: <email>, password: <password>, password_confirmation: <password>)
user.save!
```

3. Visit `<your app url>/system` and login with your system admin credentials
4. Create a new organization. Check the locales you want to use for that organization, and select a default locale.
5. Set the correct default host for the organization, otherwise the app will not work properly. Note that you need to include any subdomain you might be using.
6. Fill the rest of the form and submit it.

You're good to go!

## Applied hacks & customizations

This Decidim application comes with a bunch of customizations, some of them done via some initializer or monkey patching. Other with external plugins.

### Plugins

- [Alternative Landing](https://github.com/Platoniq/decidim-module-alternative_landing): Better content blocks for Decidim's homepage and process groups landing page
- [Decidim Awesome](https://github.com/Platoniq/decidim-module-decidim_awesome):	Usability and UX tweaks for Decidim. This plugin allows the administrators to expand the possibilities of Decidim beyond some existing limitations. All tweaks are provided in a optional fashion with granular permissions that let the administrator to choose exactly where to apply those mods. Some tweaks can be applied to any assembly, other in an specific participatory process or even in type of component only.
- [Direct Verifications](https://github.com/Platoniq/decidim-verifications-direct_verifications):	A Decidim that provides a verification method called Direct verification. Works only on the admin side, final users do not intervene in the verification process.
- [Navigation Maps](https://github.com/Platoniq/decidim-catencomu/blob/9f89837a2acf227da17c61db0df0b06a01113d36/README.md#L35):	Allows to map processes to image parts using maps.
- [CiviCRM Client](https://github.com/EFForg/ruby-civicrm): Ruby client for CiviCRM REST interface

### Customizations

#### Login page
