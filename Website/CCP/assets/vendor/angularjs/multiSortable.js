/**
  Angular directive for JQuery UI sortable.
  Built on angular-ui "uiSortable" directive.
  Adds ability to sort between multiple sortables.

  @author: Michal Ostruszka (http://michalostruszka.pl)
**/

angular.module('ui.sortable').service('ngSortableDropService', [function() {
    var ui = null;
    var model = null;
    
    this.setDraggable = function(u) {
        ui = u;
    }

    this.getDraggable = function() {
        return ui;
    }

    this.setModel = function(m) {
        model = m;
    }

    this.getModel = function() {
        return model;
    }
}]).directive('uiMultiSortable', ['uiSortableConfig', '$parse', 'ngSortableDropService', '$http', 'apiRoot', function(uiConfig, $parse, ngSortableDropService, $http, apiRoot) {
    var options = {};
    if (uiConfig.sortable !== null) {
      angular.extend(options, uiConfig.sortable);
    }

    var ModelSynchronizer = function(uiElement, attrs) {
      var MODEL_SUBSET_ATTR = 'ui-sortable-model-subset';
      var INITIAL_POSITION_ATTR = 'ui-sortable-start-pos';
      var ORIGINAL_MODEL = 'ui-sortable-original-model';
      var self = this;

      // Set some data-* attributes on element being sorted just before sorting starts
      this.appendDataOnStart = function() {
        uiElement.item.data(INITIAL_POSITION_ATTR, uiElement.item.index());
        uiElement.item.data(MODEL_SUBSET_ATTR, attrs.modelSubset);
        uiElement.item.data(ORIGINAL_MODEL, attrs.ngModel);
      };

      // Update underlying model when elements sorted within one "sortable"
      this.updateSingleSortableModel = function(model) {
        _collectDataRequiredForModelSync();
        if(_isInternalUpdate() && _hasPositionChanged()) {
          _update(model);
        }
      };

      // Update underlying model when elements sorted between different "sortables"
      this.updateMultiSortableModel = function(model) {
        _collectDataRequiredForModelSync();
        _update(model);
      };

      function _collectDataRequiredForModelSync() {
        self.data = {
          origSubset: uiElement.item.data(MODEL_SUBSET_ATTR),
          origModel: uiElement.item.data(ORIGINAL_MODEL),
          destSubset: attrs.modelSubset,
          origPosition: uiElement.item.data(INITIAL_POSITION_ATTR),
          destPosition: uiElement.item.index()
        };
      }

      function _hasPositionChanged() {
        return (self.data.origPosition !== self.data.destPosition) || !_isInternalUpdate();
      }

      function _isInternalUpdate() {
        return attrs.modelSubset === undefined || self.data.origSubset === self.data.destSubset;
      }

      function _update(model) {
        if (model.token || self.data.destPosition == -1) {
            // do nothing - droppable handles this
        } else if (attrs.modelSubset === undefined) {
            leafData = model.splice(self.data.origPosition, 1)[0];
            model.splice(self.data.destPosition, 0, leafData);
            $http.put(apiRoot.getRoot() + '/services/' + model.tree_id + '/' + model.branch_id + '/subchange/' + leafData.id, {
                newPriority: self.data.destPosition + 1,
                oldPriority: leafData.priority,
                oldBranch: model.branch_id
            });
            for (var i = 0; i < model.length; i++) {
                model[i].priority = i + 1;
            }
        } else {
            var leafData = ($parse(self.data.origSubset)(model)).splice(self.data.origPosition, 1)[0];
            if (self.data.destSubset.indexOf('leaves') != -1) {
                var destBranch = ($parse(self.data.destSubset.substring(0, 11))(model));
                $http.put(apiRoot.getRoot() + '/services/' + destBranch.tree_id + '/' + destBranch.id + '/subchange/' + leafData.id, {
                    newPriority: self.data.destPosition + 1,
                    oldPriority: leafData.priority,
                    oldBranch: leafData.branch_id
                });
                var origBranch = ($parse(self.data.origSubset)(model));
                for (var i = self.data.origPosition; i < origBranch.length; i++) {
                    origBranch[i].priority--;
                }
                leafData.branch_id = destBranch.id;
                leafData.priority = self.data.destPosition + 1;
                var newSubBranch = ($parse(self.data.destSubset)(model));
                for (var i = self.data.destPosition; i < newSubBranch.length; i++) {
                    newSubBranch[i].priority++;
                }
                newSubBranch.splice(self.data.destPosition, 0, leafData);
            }
        }
      }
    };

    return {
      require: '?ngModel',
      link: function(scope, element, attrs, ngModel) {
        var opts = angular.extend({}, options, scope.$eval(attrs.uiOptions));
        if (ngModel !== null) {
          var _start = opts.start;
          opts.start = function(e, ui) {
            ngSortableDropService.setDraggable(ui);
            ngSortableDropService.setModel(ngModel.$modelValue);
            new ModelSynchronizer(ui, attrs).appendDataOnStart();
            _callUserDefinedCallback(_start)(e, ui);
            return scope.$apply();
          };

          var _update = opts.update;
          opts.update = function(e, ui) {
            _callUserDefinedCallback(_update)(e, ui);
            return scope.$apply();
          };

          var _stop = opts.stop;
          opts.stop = function(e, ui) {
            var modelSync = new ModelSynchronizer(ui, attrs);
            modelSync.updateSingleSortableModel(ngModel.$modelValue);
            _callUserDefinedCallback(_stop)(e, ui);
            return scope.$apply();
          };

          var _receive = opts.receive;
          opts.receive = function(e, ui) {
            var modelSync = new ModelSynchronizer(ui, attrs);
            modelSync.updateMultiSortableModel(ngModel.$modelValue);
            _callUserDefinedCallback(_receive)(e, ui);
            return scope.$apply();
          };
        }
        function _callUserDefinedCallback(callback) {
          if (typeof callback === "function") {
            return callback; // regular callback
          }
          if(typeof scope[callback] === "function") {
            return scope[callback]; // $scope function as callback
          }
          return function() {}; // noop function
        }
        return element.sortable(opts);
      }
    };
  }
]).directive('jqyouiDroppable', ['ngSortableDropService', '$parse', '$http', 'apiRoot', function(ngSortableDropService, $parse, $http, apiRoot) {
    return {
      restrict: 'A',
      priority: 1,
      link: function(scope, element, attrs) {
        var updateDroppable = function(newValue, oldValue) {
          if (newValue) {
            element
              .droppable({disabled: false})
              .droppable(scope.$eval(attrs.jqyouiOptions) || {})
              .droppable({
                over: function(event, ui) {
                  var dropSettings = scope.$eval(angular.element(this).attr('jqyoui-droppable')) || [];
                  $('.card-col-placeholder').hide();
                  $('.card-leaf-placeholder').hide();
                },
                out: function(event, ui) {
                  var dropSettings = scope.$eval(angular.element(this).attr('jqyoui-droppable')) || [];
                  $('.card-col-placeholder').show();
                  $('.card-leaf-placeholder').show();
                },
                drop: function(event, ui) {
                  if (angular.isDefined(angular.element(this).attr('data-drop-model'))) {
                        var branchModel = angular.element(this).attr('data-drop-model');
                        var branchID = ($parse(branchModel)(scope)).id;
                        var draggable = ngSortableDropService.getDraggable();
                        var originalModel = ngSortableDropService.getModel();
                        var subset = draggable.item.data('ui-sortable-model-subset');
                        var index = draggable.item.data('ui-sortable-start-pos');
                        
                        var origBranch = null;
                        if (subset === undefined) {
                            origBranch = originalModel;
                        } else {
                            origBranch = ($parse(subset)(originalModel));
                        }
                        var leafData = origBranch.splice(index, 1)[0];
                        
                        $http.put(apiRoot.getRoot() + '/services/' + scope.tree.id + '/' + branchID + '/leaf/' + leafData.id);
                        for (var i = index; i < origBranch.length; i++) {
                            origBranch[i].priority--;
                        }
                  }
                }
              });
          } else {
            element.droppable({disabled: true});
          }
        };

        scope.$watch(function() { return scope.$eval(attrs.drop); }, updateDroppable);
        updateDroppable();
      }
    };
  }]);
