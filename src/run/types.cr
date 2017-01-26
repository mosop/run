module Run
  alias CommandLike = Command | CommandGroup | FiberFunction | ProcessFunction
  alias ProcessLike = Process | ProcessGroup | FunctionFiber | FunctionProcess
end
