{extends tplextends('repasrc/repasrc')}

{block name="repasrc_content"}
<div id="homeRepasRC">

<p style="margin-top:20px;text-align: center; color: #5A5A5A;font-weight: bold;font-size: 34px;line-height:40px">Bienvenue sur le calculateur d'empreinte écologique<br />
	de la restauration collective</p>

<p style="margin-top: 40px;text-align: center;color: #999;font-size: 18px;line-height:30px">	Les outils proposés ici n'ont pas vocation à être des indicateurs de performance mais sont conçus pour&nbsp;engager une réflexion sur les pratiques des restaurations collectives, pour les interroger, pour expliquer les choix effectués...<br />C'est un outil à vocation pédagogique.</p>

<div class="row-fluid" id="homeContainer">
	<ul class="thumbnails">
		<li class="span4">
			<a class="thumbnail" href="http://demo.rcresponsable.org" target="_blank">
				<img src="/mod/repasrc/img/home/calculateur.png">
			</a>
			<p>Testez le calculateur en utilisant la version <a href="http://demo.rcresponsable.org" target="_blank">demo</a></p>
		</li>
		<li class="span4">
			<a class="thumbnail" href="javascript:void(0)" onclick="showVideo()">
				<img src="/mod/repasrc/img/home/video2.png" />
			</a>
			<p>
					Regardez la <a href="javascript:void(0)" onclick="showVideo()">video</a> de présentation
			</p>
		</li>
		<li class="span4">
			{if !$smarty.session.login}
				<a class="thumbnail" href="/login">
					<img style="margin-top:62px" src="/mod/repasrc/img/home/connexion.png" />
				</a>
				<p>
					Pour vous <a href="/login">connecter</a>, utilisez le menu dans la barre&nbsp;en haut de l'écran.
				</p>
			{else}
				<a class="thumbnail" href="/compte">
					<img style="margin-top:62px" src="/mod/repasrc/img/home/informations.png" />
				</a>
				<p>
					Commencez par remplir les <a href="/compte">informations générales</a> sur votre RC
				</p>
			{/if}
		</li>
	</ul>
</div>

<div style="padding: 15px 0; text-align: center; background-color: whiteSmoke; border-top: 1px solid #ddd;border-bottom: 1px solid #DDD;">
<p class="rcr"><span style="font-size:24px;">Restauration collective responsable</span></p>
<p class="repasrc">
	<span class="big">R</span>epères pour l'<span class="big">E</span>volution des <span class="big">P</span>ratiques <span class="big">A</span>limentaires - en <span class="big">R</span>esturation <span class="big">C</span>ollective</p>
<p class="vasd">Vers une alimentation responsable, de qualité et de proximité</p>
</div>

<div id="greeting">

		<ul class="thumbnails span7">
			<li class="thumbnail">
				<div class="span4">
					Cette application a été conçue par
				</div>
				<div class="span2">
					<img src="/mod/repasrc/img/home/logos/agrocampus.png" />
				</div>
			</li>
		</ul>

		<ul class="thumbnails span7">
			<li class="thumbnail">
				<span class="span4">
					et développée par
				</span>
				<span class="span2" style="height: 90px">
					<img style="margin-top: 30px" src="/mod/repasrc/img/home/logos/croll.png" />
				</span>
			</li>
		</ul>

</div>
		
<div id="gfn">

		<ul class="thumbnails span9">
			<li class="thumbnail">
				<span class="span6">
					À partir des données d'empreinte fournies par	
				</span>
				<span class="span2" style="height: 90px">
					<img style="margin-top: 17px" src="/mod/repasrc/img/home/logos/gfn.png" />
				</span>
			</li>
		</ul>

</div>
		
<div id="financeurs">

	<div class="row">
		<ul class="thumbnails span7">
			<li class="thumbnail">
				<span class="span4" style="padding-top: 30px">
					<p>Dans le cadre du projet <b>REPAS-RC</b></p>

					<p>En partenariat avec
					- La maison de la bio du Finistère,<br /> 
					- La FR-CIVAM Bretagne</p>

					<p>Avec la participation du lycée agricole de Merdrignac, de la cuisine centrale de Lorient, de la cuisine centrale de Brest</p>
				</span>
				<span class="span2" style="padding-top: 30px">
					<div>Soutien financier</div>
					<img style="width:80px!important;height:80px!important" src="/mod/repasrc/img/home/logos/regionbretagne.png" />
				<div><b>Programme ASOSC</b></div>	
				<div>Appropriation SOciale des SCiences</div>
				</span>
			</li>
		</ul>

		<ul class="thumbnails span7">
			<li class="thumbnail">
				<span class="span4" style="padding-top: 10px">
					<p>Dans le cadre du projet <b>Restauration Collective Responsable - Biodiversité dans l'assiette</b></p>

					<p>En partenariat avec 
						- La Fondation Nicolas Hulot</p>

						<p>avec la participation du lycée agricole du Méné à Merdrignac, de la mairie de Trédaniel, du centre d'écodéveloppement de Villarceaux, du CCC</p>
					</span>
				<span class="span2" style="padding-top: 60px">
					<div>Soutien financier</div>
					<img src="/mod/repasrc/img/home/logos/iledefrance.png" />
				<div>Programme ASOSC</div>	
				<div>Appropriation SOciale des SCiences</div>
				</span>
			</li>
		</ul>
	</div>

	<div class="row">
		<ul class="thumbnails span7">
			<li class="thumbnail">
				<span class="span4" style="padding-top: 40px">
					<p>Dans le cadre du projet <b>Vers une alimentation responsables de qualité et de proximité en restauration collective</b></p>

					<p>avec la participation du lycée agricole du Méné à Merdrignac, de la mairie de Trédaniel, du centre d'écodéveloppement de Villarceaux, du CCC</p>

				</span>
				<span class="span2">
					<div>Soutien financier</div>
					<img src="/mod/repasrc/img/home/logos/bienmanger.png" />
				<div><b>Programme national pour l'alimentation</b></div>	
				</span>
			</li>
		</ul>

		<ul class="thumbnails span7">
			<li class="thumbnail">
				<span class="span4" style="padding-top: 30px">
					<p>Dans le cadre du dispositif d'appui à l'enseignement technique agricole du ministère de l'agriculture – <b>Direction générale de l'enseignement et de la recherche</b></p>

					<p>Avec la contribution des lycées agricoles de 
Merdrignac, de St Herblain, du réseau 
développement durable des lycées agricoles 
de Basse Normandie</p>
					</span>
				<span class="span2" style="padding-top: 30px">
					<div>Soutien financier</div>
					<img src="/mod/repasrc/img/home/logos/ministere.png" />
					<img style="margin-top:10px" src="/mod/repasrc/img/home/logos/enseignementagricole.png" />
				</span>
			</li>
		</ul>
	</div>


</div>
</div>

{/block}