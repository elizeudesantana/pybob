"""
pybob - menu_manutencao.py - script python menu manutencao
version="2022.01"
scriptFileVersion="0.1.0"

History:
    2022.01     Script montagem do menu.

Extern Dependency :
                pyside6

Intern Dependency:
                mgrafcpu
                mmonitorix
                mtestegraf
                mteststress
                mmemoreal
                mmonitrede
                mmonitso
                meddisco

Description:
    Montagem do menu manutencao.

by: Elizeu de Santana  In: 18/10/2022
"""
from mgrafcpu import SubmenuGrafCPU
from mmonitorix import SubmenuMonitorix
from mtestegraf import SubmenuTestGraf
from mteststress import SubmenuTestStress
from mmemoreal import SubmenuMemoriaReal
from mmonitrede import SubmenuMonitoraRede
from mmonitso import SubmenuMonitoraSO
from meddisco import SubmenuMonitoraDisco


class MenuManutencao():
    def menu_graficocpu(self):
        SubmenuGrafCPU.sub_graf()

    def menu_monitorix(self):
        SubmenuMonitorix.sub_monitorix()

    def menu_testesgraf(self):
        SubmenuTestGraf.sub_testgraf()

    def menu_stressgraf(self):
        SubmenuTestStress.sub_teststress()

    def menu_memoriareal(self):
        SubmenuMemoriaReal.sub_memoriareal()

    def menu_monitoranetwork(self):
        SubmenuMonitoraRede.sub_monitorarede()

    def menu_so(self):
        SubmenuMonitoraSO.sub_monitoraso()

    def menu_eddisco(self):
        SubmenuMonitoraDisco.sub_monitoradisco()

    def menu_hardinstalado(self):
        """Hardware_instalados_e_configurados."""
        pass

    def menu_linuxdev(self):
        """actioncontrole_do_linux_dev."""
        pass

    def menu_discos(self):
        """actionSistema_de_discos."""
        pass

    def menu_sistemadiscos(self):
        """actionSistema_de_discos_detalhados."""
        pass

    def menu_cdrom(self):
        """actionSystem_CD_ROM_Drives."""
        pass

    def menu_definedadpters(self):
        """actionDefined_Adapters_in_the_System."""
        pass

    def menu_netrouters(self):
        """actionNetwork_Routes."""
        pass

    def menu_netstatisticas(self):
        """actionNetwork_Interface_Statistics."""
        pass

    def menu_impressoras(self):
        """actionInforma_o_de_impressoras."""
        pass

    def menu_processosativos(self):
        """actionLista_de_processos_ativos."""
        pass

    def menu_drivervideo(self):
        """actionInforma_o_do_driver_de_video."""
        pass

    def menu_portas(self):
        """actionListagem_de_todas_as_portas_no_processo."""
        pass

    def menu_listaconf(self):
        """actiononfigura_o_do_sistema_listagem_completa."""
        pass

    def menu_pkginstalados(self):
        """actionListagem_dos_pacotes_instalados_no_Sistema."""
        pass

    def menu_pkgquebrados(self):
        """actionListagem_dos_pacotes_Quebrados_no_Sistema."""
        pass

    def menu_logs(self):
        """actionLista_dos_ltimos_100_users_a_logar."""
        pass

    def menu_latencia(self):
        """actionLat_ncia."""
        pass

    def menu_monta(self):
        lista_menu = [
            self.menu_graficocpu(),
            self.menu_monitorix(),
            self.menu_testesgraf(),
            self.menu_stressgraf(),
            self.menu_memoriareal(),
            self.menu_monitoranetwork(),
            self.menu_so(),
            self.menu_eddisco(),
            self.menu_hardinstalado(),
            self.menu_linuxdev(),
            self.menu_discos(),
            self.menu_sistemadiscos(),
            self.menu_cdrom(),
            self.menu_definedadpters(),
            self.menu_netrouters(),
            self.menu_netstatisticas(),
            self.menu_impressoras(),
            self.menu_processosativos(),
            self.menu_drivervideo(),
            self.menu_portas(),
            self.menu_listaconf(),
            self.menu_pkginstalados(),
            self.menu_pkgquebrados(),
            self.menu_logs(),
            self.menu_latencia()]
        return lista_menu
