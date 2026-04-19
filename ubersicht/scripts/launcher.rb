#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'

# This script defines the launcher items for the Ubersicht widget.
# It returns a JSON structure expected by the launcher.jsx widget.

LAUNCHERS = [
  {
    id: 'jira',
    label: 'JIRA',
    icon: '🎫',
    action: {
      type: 'url',
      target: 'https://transreport.atlassian.net/jira/projects?page=1&sortKey=name&sortOrder=ASC&types=software%2Cbusiness'
    }
  },
  {
    id: 'github',
    label: 'GitHub',
    icon: '🐙',
    action: {
      type: 'url',
      target: 'https://github.com/TRANSREPORT'
    }
  },
  {
    id: 'teams',
    label: 'Teams',
    icon: '💬',
    action: {
      type: 'app',
      target: 'Microsoft Teams'
    }
  },
  {
    id: 'chatgpt',
    label: 'ChatGPT',
    icon: '🤖',
    action: {
      type: 'url',
      target: 'https://chatgpt.com'
    }
  }
].freeze

payload = {
  launchers: LAUNCHERS
}

puts JSON.generate(payload)
