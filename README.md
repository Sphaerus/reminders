# Reminders

[![](https://img.shields.io/circleci/project/netguru/reminders.svg?style=flat-square)](https://circleci.com/gh/netguru/reminders)
[![](http://img.shields.io/codeclimate/github/netguru/reminders.svg?style=flat-square)](https://codeclimate.com/github/netguru/reminders)
[![](http://img.shields.io/codeclimate/coverage/github/netguru/reminders.svg?style=flat-square)](https://codeclimate.com/github/netguru/reminders)
[![](http://img.shields.io/gemnasium/netguru/reminders.svg?style=flat-square)](https://gemnasium.com/netguru/reminders)

See [CHANGELOG](https://github.com/netguru/reminders/blob/master/CHANGELOG.md) for the latest changes in the app.

## Technologies

* Ruby on Rails 4.2
* Ruby 2.2
* Postgres

## Live demo

Deploy app to Heroku using button below:

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)

You will be prompted to provide Heroku with following  credentials:

* Client ID
* Client Secret
* Slack token (optional)
* Slack enabling (optional)

### Authorisation

Our application authenticates users with Google via OAuth. You must have your
own Google project, which you can create
[here](https://console.developers.google.com/project). You can check your Client
ID and Client Secret under `Credentials` in console.

Remember to add Redirect URI for your Heroku application - it should look
similar to this:

`http://your-app-name.herokuapp.com/auth/google_oauth2/callback`

### Slack

Application can be synchronised with Slack to send notifications and fetch
channels. You can find your Slack Token
[here](https://api.slack.com/web).

## Setup

Run the following command:

```
bin/setup
```

## Development

### Guard

Keep guard running at all times:

```
bin/guard
```

### Code Style

Please follow Ruby style guide available [here](https://github.com/bbatsov/ruby-style-guide).

Use `bin/guard` to have your development process be watched by an automated tool
which checks your tests and code syntax. If you have any issues about the
feedback provided by `rubocop`, please consult it with dev team and apply
changes to `.rubocop.yml` file.

## Tests

We use RSpec 3. 

* you may need to use [Firefox 0.45esr](https://ftp.mozilla.org/pub/firefox/releases/45.0esr/) or older for feature tests to work. 

## Contributing

If you make improvements to this application, please share with others.

* Fork the project on GitHub.
* Make your feature addition or bug fix.
* Commit with Git.
* Send the author a pull request.

If you add functionality to this application, create an alternative
implementation, or build an application that is similar, please contact
me and I’ll add a note to the README so that others can find your work.

## License

MIT. See [LICENSE](https://github.com/netguru/reminders/blob/master/LICENSE).
