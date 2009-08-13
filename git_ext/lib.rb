
module Git
  class Lib
    def children_of(commit, branches)
      sha = commit.to_s
      branches = branches.to_a.map(&:to_s)

      arr_opts = ['--children']
      arr_opts += branches
      arr_opts += ['--not', "#{sha}^@"]
      arr_opts << '--'

      rev_list = command_lines('rev-list', arr_opts, false)
      rev_index_for_commit = rev_list.index { |rev_line| rev_line =~ /^#{sha}/ }
      if rev_index_for_commit
        rev_line_for_commit = rev_list[rev_index_for_commit]

        children = rev_line_for_commit.split(' ')[1..-1]
      else
        []
      end
    end
  end
end
