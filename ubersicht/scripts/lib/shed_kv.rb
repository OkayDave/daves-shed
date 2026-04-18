# frozen_string_literal: true

# Helper to interact with the shed-kv store
def shed_kv(command, key = nil, value = nil)
  bin_path = File.expand_path('../../../bin/shed-kv', __dir__)
  cmd = [bin_path, command, key, value].compact
  IO.popen(cmd).read.strip
end

def set_kv(key, value)
  shed_kv('set', key, value)
end

def get_kv(key)
  shed_kv('get', key)
end
