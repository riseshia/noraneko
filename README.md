# Noraneko

Noraneko is aim to guess unused codes, especially in a Rails project.
This gem tries to find:

- The methods not to be called in the models, helpers, concerns and plain ruby classes.
- The dead views, meaning to say, which are not rendered.

Please be careful if you want to try this, it doesn't grant detected code is
deletable, but may be deletable. Because Ruby is hard to analyze in static
as you know. I will write some cases gem couldn't detect when it becomes stable.

## Installation

```ruby
gem install noraneko
```

## Usage

```bash
noraneko path1,path2,path3 # if you don't pass, default path is '.'
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/riseshia/noraneko.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Noraneko project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/riseshia/noraneko).
