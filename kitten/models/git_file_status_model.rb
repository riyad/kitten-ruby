
require 'Qt4'

module Kitten
  module Models
    class GitFileStatusModel < Qt::AbstractTableModel
      Columns = [:path]
      ColumnName = {:path => 'Path'}
      ColumnMethod = {:path => :path}

      def initialize(repository, parent = nil)
        super(parent)
        @repository = repository


        @@added_icon = Qt::Icon.new(':/icons/16x16/status/git-file-added')
        @@deleted_icon = Qt::Icon.new(':/icons/16x16/status/git-file-deleted')
        @@modified_icon = Qt::Icon.new(':/icons/16x16/status/git-file-modified')
        @@untracked_icon = Qt::Icon.new(':/icons/16x16/status/git-file-untracked')

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
        @files = @repository.status.unstaged
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
