
require 'date'

require 'Qt4'

module Kitten
  module Models
    class GitHistoryModel < Qt::AbstractTableModel
      Columns = [:summary, :author, :authored_date]
      ColumnName = {:summary => 'Summary', :author => 'Author', :authored_date => 'Date', :id => 'Id'}
      ColumnMethod = {:summary => :short_message, :author => :author, :authored_date => :authored_date, :id => :sha}

      slots 'reset()'

      def initialize(repository, parent = nil)
        super(parent)
        @repository = repository
        self.branch = @repository.head

        @@branch_icon = Qt::Icon.new(':/icons/16x16/actions/git-branch')
        @@commit_icon = Qt::Icon.new(':/icons/16x16/actions/git-commit')
        @@merge_icon = Qt::Icon.new(':/icons/16x16/actions/git-merge')

        connect(repository.qt, SIGNAL('logChanged()'), self, SLOT('reset()'))
      end

      def columnCount(parent = nil)
        Columns.size
      end

      def columnName(column)
        ColumnName[Columns[column]]
      end

      def map_to_commit(index)
        return unless index.valid?

        @commits[index.row]
      end

      def data(index, role = Qt::DisplayRole)
        unless index.valid?
          return Qt::Variant.new
        end

        commit = map_to_commit(index)
        data = commit.send(ColumnMethod[Columns[index.column()]])
        if data.is_a?(Date)
          data = data.strftime
        else
          data = data.to_s.strip
        end

        case role
        when Qt::DisplayRole:
          Qt::Variant.new(data)
        when Qt::DecorationRole:
          if index.column() == 0
            if commit.merge?
              icon = @@merge_icon
            elsif commit.branched_on?(branch)
              icon = @@branch_icon
            else
              icon = @@commit_icon
            end
            Qt::Variant.from_value(icon)
          else
            Qt::Variant.new
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
          Qt::Variant.new(column_name(section))
        else
          Qt::Variant.new
        end
      end

      def loadCommits()
        @commits = @repository.commits(@branch.name, false)
      end

      def reset()
        @commits = []
        load_commits
        super
      end

      def rowCount(parent = nil)
        @commits.size
      end

      attr_accessor :branch
      def setBranch(branch)
        branch = @repository.get_head(branch.to_s) unless branch.is_a?(Grit::Head)
        @branch = branch
        reset
      end
    end
  end
end
