require 'open3'

# ---------------------------------------------------------------------------
# Compile the database binary once before the entire suite runs.
# We shell out through cmd so that vcvarsall.bat can set up the MSVC
# environment before invoking cl.exe.
# ---------------------------------------------------------------------------
RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.before(:suite) do
    project_root = File.expand_path('..', __dir__)
    build_bat    = File.join(project_root, 'build.bat')

    stdout, stderr, status = Open3.capture3('cmd', '/c', build_bat, chdir: project_root)
    unless status.success?
      abort "Compilation failed!\nSTDOUT: #{stdout}\nSTDERR: #{stderr}"
    end
  end
end

# ---------------------------------------------------------------------------
# Helper: spawn the DB binary, feed it a list of commands, return output lines.
# Uses Open3.capture2 to avoid pipe-buffer deadlocks on large output.
# Forces binary encoding to tolerate any byte sequence from the C binary.
# ---------------------------------------------------------------------------
def run_script(commands)
  binary    = File.expand_path('../build/main.exe', __dir__)
  stdin_str = commands.map { |c| "#{c}\n" }.join

  stdout, = Open3.capture2(binary, stdin_data: stdin_str, binmode: true)
  stdout
    .force_encoding('UTF-8')
    .encode('UTF-8', invalid: :replace, undef: :replace)
    .split("\n")
    .map(&:strip)
    .reject(&:empty?)
end
