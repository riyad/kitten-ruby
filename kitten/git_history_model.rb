
require 'Qt4'

module Kitten
  class GitHistoryModel < Qt::AbstractTableModel
    Columns = [:summary, :author, :author_date, :id]
    ColumnName = {:summary => 'Summary', :author => 'Author', :author_date => 'Date', :id => 'Id'}
    ColumnMethod = {:summary => :message, :author => :author, :author_date => :author_date, :id => :sha}

    def initialize(repository, parent = nil)
      super(parent)
      @repository = repository
      loadCommits()
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
      return Qt::Variant.new(data)
    end

    def headerData(section, orientation = Qt::Horizontal, role = Qt::DisplayRole)
      if section > columnCount() || orientation != Qt::Horizontal || role != Qt::DisplayRole
        return Qt::Variant.new
      end

      return Qt::Variant.new(columnName(section))
    end

    def loadCommits()
      @commits = []
      @log = @repository.log
      @log.each { |commit| @commits << commit }
    end

    def rowCount(parent = nil)
      @log.size
    end
  end
end
