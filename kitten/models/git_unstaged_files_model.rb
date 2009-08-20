
require 'Qt4'

module Kitten
  module Models
    class GitUnstagedFilesModel < Qt::AbstractTableModel
      Columns = [:path]
      ColumnName = {:name => 'Name', :path => 'Path'}
      ColumnMethod = {:name => :name, :path => :path}

      def initialize(repository, parent = nil)
        super(parent)
        @repository = repository
        load_files
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

        status_file = map_to_status_file(index)

        case Columns[index.column]
        when :name:
          Qt::Variant.new(File.basename(status_file.path))
        when :path:
          Qt::Variant.new(status_file.path)
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
        @files = []
        diffs = @repository.lib.diff_files
        status = @repository.status
        @files += status.added
        @files += status.changed
        @files += status.deleted
        @files += status.untracked
      end

      def map_to_status_file(index)
        return unless index.valid?

        @files[index.row][1]
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
