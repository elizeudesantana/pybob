from bob.lib.distancia import Position


def test_distancia():
    # criar codigo para parsear atras das coordenadas na web, atraves de
    # location
    y = Position('Casa y', -22.903, -43.697)
    x = Position('Casa x', -22.929, -43.632)

    assert (y.distance_to(x)) == 7.524167990696799
