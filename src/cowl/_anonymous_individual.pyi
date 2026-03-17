from ._individual import Individual

class AnonymousIndividual(Individual):
    def __init__(self, node_id: str | None = None) -> None: ...
