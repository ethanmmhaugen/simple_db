RSpec.describe 'database' do

  it 'inserts and retrieves a row' do
    result = run_script([
      'insert 1 user1 person1@example.com',
      'select',
      '.exit',
    ])
    expect(result).to include(
      'db > Executed Successfully.',
      'db > (1, user1, person1@example.com)',
      'Executed Successfully.',
    )
  end

  it 'prints an error when the table is full' do
    # ROW_SIZE = 4 + 32 + 255 = 291 bytes
    # ROWS_PER_PAGE = 4096 / 291 = 14
    # TABLE_MAX_ROWS = 14 * 100 = 1400
    # execute_insert checks num_rows >= TABLE_MAX_ROWS,
    # so inserts 1-1400 succeed and the 1401st returns "Error. Table Full."
    commands = (1..1401).map { |i| "insert #{i} user#{i} user#{i}@example.com" }
    commands << '.exit'

    result = run_script(commands)
    expect(result).to include('db > Error. Table Full.')
  end

  it 'allows inserting strings that are the maximum length' do
    # sscanf %s copies at most field_width-1 chars + null, so effective
    # max is USERNAME_SIZE-1 (31) and EMAIL_SIZE-1 (254).
    long_username = 'a' * 31
    long_email    = 'a' * 254
    result = run_script([
      "insert 1 #{long_username} #{long_email}",
      'select',
      '.exit',
    ])
    expect(result).to include("db > (1, #{long_username}, #{long_email})")
  end

  it 'keeps data after inserting multiple rows' do
    result = run_script([
      'insert 1 alice alice@example.com',
      'insert 2 bob bob@example.com',
      'insert 3 charlie charlie@example.com',
      'select',
      '.exit',
    ])
    # Only the first selected row gets the "db > " prefix from the prompt;
    # subsequent rows are printed directly by printf inside execute_select.
    expect(result).to include('db > (1, alice, alice@example.com)')
    expect(result).to include('(2, bob, bob@example.com)')
    expect(result).to include('(3, charlie, charlie@example.com)')
  end

  it 'prints an error for an unrecognized dot command' do
    result = run_script([
      '.unknown',
      '.exit',
    ])
    expect(result).to include("db > Command Unrecognized '.unknown'")
  end

  it 'prints a syntax error for a malformed insert' do
    result = run_script([
      'insert foo bar',
      '.exit',
    ])
    expect(result).to include('db > Syntax error. Could not parse statement.')
  end

  it 'prints an error for an unrecognized statement' do
    result = run_script([
      'relics',
      '.exit',
    ])
    expect(result).to include(match(/Unrecognized keyword/))
  end

end
