
require 'Qt4'

module Kitten
  class GitHistoryModel < Qt::AbstractTableModel
    Columns = [:summary, :author, :author_date, :id]
    ColumnName = {:summary => 'Summary', :author => 'Author', :author_date => 'Date', :id => 'Id'}
    ColumnMethod = {:summary => :message, :author => :author, :author_date => :author_date, :id => :sha}

    def initialize(repository, parent = nil)
      super(parent)
      @repository = repository
      self.branch = @repository.current_branch
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

      data = @commits[index.row].send ColumnMethod[Columns[index.column()]]
      if data.is_a? Git::Author
        data = data.name
      elsif data.is_a? Date
        data = data.strftime
      else
        data = data.to_s
      end
      return Qt::Variant.new data
    end

    def headerData(section, orientation = Qt::Horizontal, role = Qt::DisplayRole)
      if section > column_count || orientation != Qt::Horizontal || role != Qt::DisplayRole
        return Qt::Variant.new
      end

      Qt::Variant.new column_name(section)
    end

    def loadCommits()
      @log = @repository.log.object(@branch)
      @log.each { |commit| @commits << commit }
    end

    def reset()
      @commits = []
      load_commits
      super
    end

    def rowCount(parent = nil)
      @log.size
    end

    def setBranch(branch)
      @branch = branch
      reset
    end
  end
end
