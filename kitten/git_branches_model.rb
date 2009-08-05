
require 'Qt4'

module Kitten
  class GitBranchesModel < Qt::AbstractTableModel
    Columns = [:name, :id]
    ColumnName = {:name => 'Name'}
    ColumnMethod = {:name => :name}

    def initialize(repository, parent = nil)
      super(parent)
      @repository = repository
      loadBranches()
    end

    def columnCount(parent = nil)
      Columns.size
    end

    def columnName(column)
      ColumnName[Columns[column]]
    end

    def data(index, role = Qt::DisplayRole)
       if !index.valid? || role != Qt::DisplayRole
        return Qt::Variant.new
      end

      data = @branches[index.row].send ColumnMethod[Columns[index.column()]]
      return Qt::Variant.new(data)
    end

    def headerData(section, orientation = Qt::Horizontal, role = Qt::DisplayRole)
      if section > columnCount() || orientation != Qt::Horizontal || role != Qt::DisplayRole
        return Qt::Variant.new
      end

      return Qt::Variant.new(columnName(section))
    end

    def loadBranches()
      @branches = @repository.branches.local
    end

    def reset()
      @commits = []
      loadBranches()
      super
    end

    def rowCount(parent = nil)
      @branches.size
    end
  end
end
