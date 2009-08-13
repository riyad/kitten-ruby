
require 'git'

require 'Qt4'

module Kitten
  class GitHistoryModel < Qt::AbstractTableModel
    Columns = [:summary, :author, :author_date]
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
       if !index.valid?
        return Qt::Variant.new
      end

      commit = @commits[index.row]
      data = commit.send ColumnMethod[Columns[index.column()]]
      if data.is_a? Git::Author
        data = data.name
      elsif data.is_a? Date
        data = data.strftime
      else
        data = data.to_s.strip
      end

      case role
      when Qt::DisplayRole:
        Qt::Variant.new data
      when Qt::DecorationRole:
        unless Columns[index.column()] == :summary
          Qt::Variant.new
        else
          # TODO: find a way to detect branches
          if commit.merge?
            icon = Qt::Icon.new(':/icons/16x16/actions/git-merge')
          else
            icon = Qt::Icon.new(':/icons/16x16/actions/git-commit')
          end
          Qt::Variant.from_value icon
        end
      else
        Qt::Variant.new
      end
    end

    def headerData(section, orientation = Qt::Horizontal, role = Qt::DisplayRole)
      if section > column_count || orientation != Qt::Horizontal
        return Qt::Variant.new
      end

      case role
      when Qt::DisplayRole:
        Qt::Variant.new column_name(section)
      else
        Qt::Variant.new
      end
    end

    def loadCommits()
      @log = @repository.log.object(@branch)
      @commits = @log.commits
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
