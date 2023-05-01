mixin IUseCase<R, P> {
  Future<R> execute({required P params});
}

class NoParams {
  const NoParams();
}