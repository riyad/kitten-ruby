
module Git
  class Log
    def commits
      check_log
      @commits
    end
  end
end
