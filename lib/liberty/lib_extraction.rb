require 'pycall/import'
include PyCall::Import

pyimport 'liberty.parser', as: :liberty_parser
pyimport 'liberty.types', as: :liberty_types

# --------------------------
# Wrapper Classes
# --------------------------

module Liberty
  class ASTNode 
    ::Visitable
  end

  class LibertyLibrary < ASTNode
    def initialize(filename)
      pyimport 'liberty.parser', as: :liberty_parser
      pyimport 'liberty.types', as: :liberty_types
      text = File.read(filename)
      @pyobj = liberty_parser.parse_liberty(text)
    end

    def time_unit
      @pyobj['time_unit'].to_s.tr('"','')
    end

    def cells
      @pyobj.get_groups('cell').map { |c| LibertyCell.new(c) }
    end

    def get_cell cell_name
      LibertyCell.new(liberty_types.select_cell(@pyobj, cell_name))
    end

    def get_cell_timings cell_name
      c = get_cell(cell_name)
      outputs = c.pins.select{|p| p.direction == 'output'}
      rise_max_a = []
      fall_max_a = []
      rise_mean_a = []
      fall_mean_a = []
      outputs.each do |o|
        o_timing_arcs = o.timing_arcs
        o_timing_arcs.each do |table|
          t_cell_rise = table.cell_rise.flatten
          t_cell_fall = table.cell_fall.flatten
          
          rise_max_a << t_cell_rise.max
          fall_max_a << t_cell_fall.max
          rise_mean_a << (t_cell_rise.sum / t_cell_rise.length.to_f).round(10)
          fall_mean_a << (t_cell_fall.sum / t_cell_rise.length.to_f).round(10)
        end
      end
      {
        max_cell_rise: rise_max_a.max,
        max_cell_fall: fall_max_a.max,
        mean_cell_rise: (rise_mean_a.sum / rise_mean_a.length.to_f).round(10),
        mean_cell_fall: (fall_mean_a.sum / fall_mean_a.length.to_f).round(10)
      }
    end
  end

  class LibertyCell < ASTNode
    def initialize(pyobj)
      @pyobj = pyobj
    end

    def name
      @pyobj.args.first.to_s
    end

    def pins
      @pyobj.get_groups('pin').map { |p| LibertyPin.new(p) }
    end

    def outputs
      pins.select{|p| p.direction == 'output'}
    end

    def get_pin_named pin_name
      LibertyPin.new(liberty_types.select_cell(@pyobj, pin_name))
    end
  end

  class LibertyPin < ASTNode
    def initialize(pyobj)
      @pyobj = pyobj
    end

    def name
      @pyobj.args.first.to_s
    end

    def direction
      @pyobj['direction']
    end

    def function
      @pyobj['function'].to_s
    end

    def timing_arcs
      @pyobj.get_groups('timing').map { |t| LibertyTiming.new(t) }
    end
  end

  class LibertyTiming < ASTNode
    def initialize(pyobj)
      @pyobj = pyobj
    end

    def related_pin
      @pyobj['related_pin']
    end

    def timing_type
      @pyobj['timing_type']
    end

    def cell_rise
      extract_table(@pyobj.get_groups('cell_rise'))
    end

    def cell_fall
      extract_table(@pyobj.get_groups('cell_fall'))
    end

    def rise_transition
      extract_table(@pyobj.get_groups('rise_transition'))
    end

    def fall_transition
      extract_table(@pyobj.get_groups('fall_transition'))
    end

    private

    def extract_table(groups)
      return nil if groups.length == 0
      group = groups.first
      values = group['values'].to_a
      return nil if values.length == 0

      # Convert Liberty table string into nested float arrays
      values.map! do |row|
        row.to_s.tr('"','').split(',').map(&:to_f)
      end
    end
  end

end