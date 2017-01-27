module Run
  lib C
    fun dup2(oldfd : LibC::Int, newfd : LibC::Int) : LibC::Int
  end
end
