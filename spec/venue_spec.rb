#!/usr/bin/env ruby
# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength, Lint/MissingCopEnableDirective
RSpec.describe Venue do
  it 'has a version number' do
    expect(Venue::VERSION).not_to be nil
  end

  context 'when there are no venue files' do
    let(:original_env) { Hash[**ENV] }

    it 'a copy equals the original' do
      env = Hash[**ENV]
      expect(env).to eq(original_env)
    end

    it 'shows ENV differs when a key/value pair is removed' do
      env = Hash[**ENV]
      env['EXTRA'] = 'I should not be here'
      expect(env).not_to eq(original_env)
    end
  end

  context 'when checking the with_files helper' do
    it 'correctly creates test files' do
      with_files(a: 'a') do
        expect(File.exist?('a')).to be_truthy
      end
    end

    it 'correctly removes test files' do
      with_files(a: 'a') {}
      expect(File.exist?('a')).to be_falsey
    end
  end

  context 'when dotfiles has no .env file at all' do
    it 'should make venue fail since it cannot find .env' do
      without_files('.env') do
        _results, err, _st = run_cmd('exe/venue', 'env')
        expect(err).not_to be_empty
      end
    end
  end

  context 'when VENUE_DOTFILES is set' do
    it 'should look only at the files in VENUE_DOTFILES' do
      with_files(a: "A=a\n", b: "B=b\n") do
        results, _err, _st = run_cmd('exe/venue', '-f', 'a,b', 'env')
        culled = line_filter results, /^[A-Z]=/
        expect(culled).to eq(['A=a', 'B=b'])
      end
    end
  end
end
