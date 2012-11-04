//  -*- mode:js; tab-width:2; c-basic-offset:2; -*-
var Paginator = new Class({

	Implements: [Events, Options],
	options: {
		rowsperpage: 10,
		rowscount: 0,
		page: 0,
		onSelect: function(infos) {}
	},

	initialize: function(el, options) {
		this.setOptions(options);
		this.rowsperpage=this.options.rowsperpage;
		this.rowscount=this.options.rowscount;
		this.container = el;
		this.page = this.options.page;
		this.paginationContainer = {};
		var me=this;
		this._updateDisplay();
	},

	setRowsPerPage: function(rowsperpage) {
		this.rowsperpage=rowsperpage;
		this._updateDisplay();
	},

	setRowsCount: function(rowscount) {
		this.rowscount=rowscount;
		this._updateDisplay();
	},

		// la page 0 est la premiere page (affichée 1)
		setCurPage: function(page) {
			var pagescount = Math.floor((this.rowscount-1) / this.rowsperpage) +1;
			if ((page >= 0) && (page <= pagescount) && (page != this.page)) {
				this.page = page;
				this.fireEvent('select', {
					'page': page,
					'offset': page*this.rowsperpage,
					'rowsperpage': this.rowsperpage
				});
				this._updateDisplay();
			}
		},

					_updateDisplay: function() {
						var pagescount = Math.floor((this.rowscount-1) / this.rowsperpage) +1;
						this.container.empty();
						if (pagescount < 2) return false;
						this.container.empty();

						this.paginationContainer = new Element('ul');

						this.elem_prev = new Element('li').adopt(new Element('a', {'text': '«'})).inject(this.paginationContainer);

						if (this.page > 0) {
							this.elem_prev.removeClass('disabled');
							this.elem_prev.addEvent('click', function() {
								this.setCurPage(this.page-1);
							}.bind(this));
						} else {
							this.elem_prev.addClass('disabled');
						}

						if (this.page > 3) {
							for (var i=0; i<3; i++) {
								this._displayNum(i);
							}
							this.paginationContainer.adopt(new Element('li').adopt(new Element('a', { text: ' ... ', 'class': 'disabled' })));
							for (var i=(this.page-2); i<this.page; i++) {
								this._displayNum(i);
							}
						} else {
							for (var i=0; i<this.page; i++) this._displayNum(i);
						}

						if (this.rowscount > 0) {
							this._displayNum(this.page, true);
						}

						if ((this.page+1) < (pagescount - 3)) {
							for (var i=(this.page+1); i<(this.page+3); i++) {
								this._displayNum(i);
							}
							this.paginationContainer.adopt(new Element('li').adopt(new Element('a', { text: ' ... ' })));
							for (var i=(pagescount-3); i<pagescount; i++) {
								this._displayNum(i);
							}
						} else {
							for (var i=(this.page+1); i<pagescount; i++) {
								this._displayNum(i);
							}
						}

						this.elem_next = new Element('li').adopt(new Element('a', {'text': '»'})).inject(this.paginationContainer);
						if (this.page < (pagescount-1)) {
						 this.elem_next.removeClass('disabled');
							this.elem_next.addEvent('click', function() {
								this.setCurPage(this.page+1);
							}.bind(this));
						} else {
							this.elem_next.addClass('disabled');
						}

						this.container.adopt(this.paginationContainer);
					},

		_displayNum: function(i, activate) {
			var el = new Element('li').adopt(new Element('a', {'text': i+1}));
			if (activate === true) {
				el.addClass('active');
			}
			el.addEvent('click', function(e) {
				var page=parseInt(e.target.get('text')) - 1;
				this.setCurPage(page);
			}.bind(this));
			this.paginationContainer.adopt(el);
		},
	});
