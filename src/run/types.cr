module Run
  alias CommandLike = Command | CommandGroup | FiberFunction | ProcessFunction
  alias ProcessLike = CommandProcess | ProcessGroup | FunctionFiber | FunctionProcess
end
