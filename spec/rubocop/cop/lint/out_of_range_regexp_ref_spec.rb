# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::OutOfRangeRegexpRef do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  it 'registers an offense when references are used before any Regexp' do
    expect_offense(<<~RUBY)
      puts $3
           ^^ Do not use out of range reference for the Regexp.
    RUBY
  end

  it 'registers an offense when out of range references are used for named captures' do
    expect_offense(<<~RUBY)
      /(?<foo>FOO)(?<bar>BAR)/ =~ "FOOBAR"
      puts $3
           ^^ Do not use out of range reference for the Regexp.
    RUBY
  end

  it 'registers an offense when out of range references are used for numbered captures' do
    expect_offense(<<~RUBY)
      /(foo)(bar)/ =~ "foobar"
      puts $3
           ^^ Do not use out of range reference for the Regexp.
    RUBY
  end

  it 'registers an offense when out of range references are used for mix of numbered and named captures' do
    expect_offense(<<~RUBY)
      /(?<foo>FOO)(BAR)/ =~ "FOOBAR"
      puts $2
           ^^ Do not use out of range reference for the Regexp.
    RUBY
  end

  it 'registers an offense when out of range references are used for non captures' do
    expect_offense(<<~RUBY)
      /bar/ =~ 'foo'
      puts $1
           ^^ Do not use out of range reference for the Regexp.
    RUBY
  end

  it 'does not register offense to a regexp with valid references for named captures' do
    expect_no_offenses(<<~RUBY)
      /(?<foo>FOO)(?<bar>BAR)/ =~ "FOOBAR"
      puts $1
      puts $2
    RUBY
  end

  it 'does not register offense to a regexp with valid references for numbered captures' do
    expect_no_offenses(<<~RUBY)
      /(foo)(bar)/ =~ "foobar"
      puts $1
      puts $2
    RUBY
  end

  it 'does not register offense to a regexp with valid references for a mix named and numbered captures' do
    expect_no_offenses(<<~RUBY)
      /(?<foo>FOO)(BAR)/ =~ "FOOBAR"
      puts $1
    RUBY
  end

  # RuboCop does not know a value of variables that it will contain in the regexp literal.
  # For example, `/(?<foo>#{var}*)` is interpreted as `/(?<foo>*)`.
  # So it does not offense when variables are used in regexp literals.
  it 'does not register an offence Regexp containing non literal' do
    expect_no_offenses(<<~'RUBY')
      var = '(\d+)'
      /(?<foo>#{var}*)/ =~ "12"
      puts $1
      puts $2
    RUBY
  end
end
