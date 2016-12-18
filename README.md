# Pecorb

This is a simple CLI tool to generate a user-selectable menu.  
It is based on `inquirer.js` and `peco` (which itself is based on `percol`).

The above mentioned tools are all more feature rich than this one (and I'm sure
the code is better too), but I wanted a few different features:

- A list that can be navigated using the keyboard (like `enquirer`)
- Fuzzy filterable (like `ctrl-p` in vim, etc.)
- Not take over the entire screen (like curses interfaces normally do)
- Dependency free (except for development dependencies)


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pecorb'
```

And then execute:
```
$ bundle
```

Or install it system wide for use on the command line:
```
$ gem install pecorb
```


## Usage

For use on the command-line:

```
ls | pecorb | cat
pecorb myFile.txt
```

For use in a ruby program:

```ruby
result = Pecorb.list %w[Apples Bananas Cake Donuts]
result = Pecorb.list %w[Apples Bananas Cake Donuts], prompt: "Favourite food: "
```


## Key Bindings

- `up` and `ctrl-k` will move up through the list
- `down` and `ctrl-j` will move down through the list
- `ctrl-l` will clear the screen and re-print the menu
- `crtl-c` and `escape` will exit (with exit code `0`)
- `ctrl-d` (`eof`) and `enter` (`\r`) will select the item
- `baskspace`, `left` and `right` do what you would expect


## Status

Currently this seems to work well on the command line and as a ruby library.

There are some tests but not great coverage. The complex parts are mainly the
paging logic (which does have tests) and the random access terminal printing
that makes up the user interface (which doesn't have tests).


## Development

After checking out the repo, run `bundle install` to install dependencies.

To install this gem onto your local machine, run `bundle exec rake install`.
To release a new version, update the version number in `version.rb`, and then
run `bundle install` and `bundle exec rake release`, which will create a git
tag for the version, push git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).


## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/stevenocchipinti/pecorb.


## License

The gem is available as open source under the terms of the
[MIT License](http://opensource.org/licenses/MIT).


## Kudos

Inspiration and education came from these resources:
- [inquirer.js](https://github.com/SBoudrias/Inquirer.js/)
- [inquirer.rb](https://github.com/arlimus/inquirer.rb)
- [peco](https://github.com/peco/peco)
- [percol](https://github.com/mooz/percol)
- [Random Access Terminal - Blog Post](http://graysoftinc.com/terminal-tricks/random-access-terminal)
- [ANSI Escape Codes - Wikipedia](https://en.wikipedia.org/wiki/ANSI_escape_code)
