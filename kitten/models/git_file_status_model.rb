
require 'Qt4'

module Kitten
  module Models
    class GitFileStatusModel < Qt::AbstractTableModel
      Columns = [:path]
      ColumnName = {:path => 'Path'}
      ColumnMethod = {:path => :path}

      slots 'reset()'

      # status can be any of
      #   :all for all of the files
      #
      #   :added     for only the added files
      #   :deleted   for only the deleted files
      #   :modified  for only the modified files
      #   :untracked for only the untracked files
      #
      #   :staged   for only the staged
      #   :unstaged for only the unstaged
      def initialize(repository, status, parent = nil)
        super(parent)
        @repository = repository

        @status = status

        @@added_icon = Qt::Icon.new(':/icons/16x16/status/git-file-added')
        @@deleted_icon = Qt::Icon.new(':/icons/16x16/status/git-file-deleted')
        @@modified_icon = Qt::Icon.new(':/icons/16x16/status/git-file-modified')
        @@untracked_icon = Qt::Icon.new(':/icons/16x16/status/git-file-untracked')

        connect(repository.qt, SIGNAL('stageChanged()'), self, SLOT('reset()'))

        load_files
      end

      def columnCount(parent = nil)
        Columns.size
      end

      def columnName(column)
        ColumnName[Columns[column]]
      end

      def data(index, role = Qt::DisplayRole)
        unless index.valid?
          return Qt::Variant.new
        end

        status_file = map_to_status_file(index)

        case role
        when Qt::DisplayRole:
          Qt::Variant.new(status_file.send(ColumnMethod[Columns[index.column]]))
        when Qt::DecorationRole:
          if index.column() == 0
            if status_file.added?
              icon = @@added_icon
            elsif status_file.deleted?
              icon = @@deleted_icon
            elsif status_file.modified?
              icon = @@modified_icon
            else
              icon = @@untracked_icon
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
        if section > column_count || orientation != Qt::Horizontal || role != Qt::DisplayRole
          return Qt::Variant.new
        end

        return Qt::Variant.new(column_name(section))
      end

      def loadFiles()
        case @status
        when :staged
          @files = @repository.status.staged_changes
        when :unstaged
          @files = @repository.status.unstaged_changes
        else
          @files = @repository.status.to_a
        end
      end

      def map_to_index(status_file)
        row = @files.index { |sf| sf.path == status_file.path && (sf.sha_repo == status_file.sha_repo if status_file.sha_repo) }
        index(row, 0)
      end

      def map_to_status_file(index)
        return unless index.valid?

        @files[index.row]
      end

      def reset()
        load_files
        super
      end

      def rowCount(parent = Qt::ModelIndex.new)
        @files.size
      end
    end
  end
end
