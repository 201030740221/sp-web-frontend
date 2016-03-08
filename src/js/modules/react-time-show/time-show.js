/**
 * 按时间区间显示对应视图
 */

import DATE from 'modules/sp/date';

export default class TimeShow extends React.Component {

    constructor(props) {
        super(props);
    }

    timeIn() {
        let now = DATE.getTime();
        let start = DATE.getTime(this.props.start);
        let end = DATE.getTime( this.props.end );

        // 如果在时间区间内的，则返回 true
        if( this.props.start && this.props.end ){
            return start-now<0 && end-now>0;
        }else if(this.props.start && !this.props.end){
            return start-now<0
        }else if(!this.props.start && this.props.end){
            return end-now>0;
        }else{
            return true;
        }

    }

    render() {
        let condition = true;

        if(this.props.condition){ // 可传入条件
            for(let key in this.props.condition){
                if(!this.props.condition[key]){
                    condition = false;
                }
            }
        }

        // 全局隐藏
        if( this.props.hide ){
            return null;
        }
        // 如果全局显示或者满足条件就显示
        if( this.props.show || (this.timeIn() && condition) ){
            return this.props.children;
        }
        return null;
    }

}
