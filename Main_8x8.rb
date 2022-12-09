require 'benchmark'

class SudokuSolver
  def solve(puzzle)
    solution = Marshal.load(Marshal.dump(puzzle))

    if solve_helper(solution)
      return solution
    end

    nil
  end

  def solve_helper(solution)
    min_possible_value_count_cell = nil

    while true
      min_possible_value_count_cell = nil

      (0..8).each do |row_index|
        (0..8).each do |column_index|
          if solution[row_index][column_index] != 0
            next
          end

          possible_values = find_possible_values(row_index, column_index, solution)
          possible_values_count = possible_values.length

          if possible_values_count == 0
            return false
          end
          if possible_values_count == 1
            solution[row_index][column_index] = possible_values.pop
          end

          if min_possible_value_count_cell.nil? or possible_values_count < min_possible_value_count_cell[1].length
            min_possible_value_count_cell = [[row_index, column_index], possible_values]
          end
        end
      end

      if min_possible_value_count_cell.nil?
        return true
      end
      if 1 < min_possible_value_count_cell[1].length
        break
      end
    end

    r, c = min_possible_value_count_cell[0]

    min_possible_value_count_cell[1].each do |val|
      solution_copy = Marshal.load(Marshal.dump(solution))
      solution_copy[r][c] = val

      if solve_helper(solution_copy)
        (0..8).each do |row_index|
          (0..8).each do |column_index|
            solution[row_index][column_index] = solution_copy[row_index][column_index]
          end
        end
        return true
      end
    end

    false
  end

  def find_possible_values(row_index, column_index, puzzle)
    values = (1..9).to_a

    values -= get_row_values(row_index, puzzle)
    values -= get_column_values(column_index, puzzle)
    values -= get_block_values(row_index, column_index, puzzle)
  end

  def get_row_values(row_index, puzzle)
    puzzle[row_index].uniq
  end

  def get_column_values(column_index, puzzle)
    column = Array.new

    (0..8).each do |idx|
      column << puzzle[idx][column_index]
    end

    column.uniq
  end

  def get_block_values(row_index, column_index, puzzle)
    block_row_start = 3 * ((row_index / 3).floor)
    block_column_start = 3 * ((column_index / 3).floor)
    block = Array.new

    (0..2).each do |r|
      (0..2).each do |c|
        block << puzzle[block_row_start + r][block_column_start + c]
      end
    end

    block.uniq
  end
end

def print_puzzle(puzzle)
  puzzle.each { |row|
    print("#{row}\n")
  }
end

puzzle = [
  [0, 0, 0, 0, 6, 0, 7, 0, 0],
  [0, 5, 9, 0, 0, 0, 0, 0, 0],
  [0, 1, 0, 2, 0, 0, 0, 0, 0],
  [0, 0, 0, 1, 0, 0, 0, 0, 0],
  [6, 0, 0, 5, 0, 0, 0, 0, 0],
  [3, 0, 0, 0, 0, 0, 4, 6, 0],
  [0, 0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 9, 1],
  [8, 0, 0, 7, 4, 0, 0, 0, 0]
]

puts "Input Sudoku:\n"
print_puzzle(puzzle)

sudoku = SudokuSolver.new
start_time = Time.now.to_f
solution = sudoku.solve(puzzle)
finish_time = Time.now.to_f

if solution
  puts "\nSolved Sudoku: "
  print_puzzle(solution)
else
  puts "\nSudoku has no solutions."
end

puts "Time used: #{finish_time - start_time} seconds"
puts Benchmark.measure { sudoku.solve(puzzle) }.real
