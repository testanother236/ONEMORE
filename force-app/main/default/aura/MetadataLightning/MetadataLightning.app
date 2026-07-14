<aura:application controller="AwesomeProductController">
    <ltng:require styles="/resource/bootstrap"/>
    <aura:handler name="init" value="{!this}" action="{!c.doInit}" />
    <aura:attribute name="records" type="Account[]" />
	temp Desc
    <ltng:require styles="/resource/bootstrap"/>
    <table border="1">
        <aura:iteration items="{!v.records}" var="rec">
            <tr>
                <td><ui:outputText value="{!rec.Id}" /></td>
                <td><ui:outputText value="{!rec.Name}" /></td>
            </tr>
            <!--<tr>
                <td><ui:outputText value="{!rec.Id}" /></td>
                <td><ui:outputText value="{!rec.Name}" /></td>
            </tr>-->
        </aura:iteration>
    </table>
    <aura:iteration items="{!v.records}" var="rec">
        <div class="row-fluid">
            <div class="col-xs-12 fullwidth">
            	<div class="panel panel-primary">
                  	<div class="panel-heading">
                    	<h3 class="panel-title">{!rec.Name}</h3>
                	</div>
                </div>
            </div>
       	</div>
    </aura:iteration>
    <!--<aura:iteration items="{!v.records}" var="rec">
        <div class="row-fluid">
            <div class="col-xs-12 fullwidth">
            	<div class="panel panel-primary">
                  	<div class="panel-heading">
                    	<h3 class="panel-title">{!rec.Name}</h3>
                	</div>
                </div>
            </div>
       	</div>
    </aura:iteration>-->
          
</aura:application>